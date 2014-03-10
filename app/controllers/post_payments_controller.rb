class PostPaymentsController < ApplicationController

  before_filter :authenticate_user!

  def create
    post = Post.for_user(current_user).find(params[:post_id])

    unless current_user.is_publisher? && post.present?
      redirect_to root_path and return
    end

    product = $payments[:product][:post_edit]

    if post_payment_params.present?
      token = post_payment_params[:stripe_token]
      email = post_payment_params[:email]
    end

    card = params[:card]

    # Create or retrieve Stripe customer
    if current_user.stripe_customer_id?
      customer = Stripe::Customer.retrieve(current_user.stripe_customer_id)
      email = customer.email

      if token.present?
        customer.cards.create(card: token)
      end
    else
      customer = Stripe::Customer.create(
        email: email,
        card: token,
        description: current_user.id,
      )

      # Assign stripe customer id to the user
      if customer.present?
        current_user.stripe_customer_id = customer.id
        current_user.save
      end
    end

    # Create the charge on Stripe's servers - this will charge the user's card
    begin
      stripe_params = {
        amount: product[:price],
        currency: $payments[:currency],
        description: "Payment for POST ID #{post.id}",
      }

      stripe_params[:customer] = customer.id if current_user.stripe_customer_id?
      stripe_params[:card] = token if token.present?

      charge = Stripe::Charge.create(stripe_params)
    rescue Stripe::CardError => e
      logger.debug e
      redirect_to edit_post_path(post), alert: e.message and return
    end

    # Create payment entry in our database
    @post_payment = current_user.posts.find(post.id).post_payments.build(
      user_id:        current_user.id,
      product_id:     product[:id],
      email:          email,
      amount:         product[:price],
      currency:       $payments[:currency],
      status:         (charge.paid == true ? $payments[:status][:paid] : $payments[:status][:not_paid]),
      stripe_token:   (token.present? ? token : 'cc_on_file'),
      stripe_response: charge.to_json,
    )

    @post_payment.merge!(stripe_err_message: charge.failure_message, stripe_err_code: charge.failure_code) if (charge.failure_code && charge.failure_message)

    if @post_payment.save
      @post_payment.post.state_machine.transition_to(:paid)
    end

    respond_to do |format|
      if @post_payment.persisted?
        format.json { render json: @post_payment, status: :created, location: @post_payment  }
        format.html { redirect_to posts_path, notice: 'Success! You can now submit your post and an Editor will be assigned as soon as possible.' }
      else
        format.json { render json: @post_payment.errors, status: :unprocessable_entity }
        format.html { redirect_to edit_post_path(post), alert: 'Something went wrong with your payment. Please send us a message at <a href="mailto:support@twitter">support@twitterpen</a>' }
      end
    end
  end

  private
    def post_payment_params
      params.require(:post_payment).permit(:stripe_token, :email) if params[:post_payment]
    end
end

class PostPaymentsController < ApplicationController

  before_filter :authenticate_user!

  def create
    product = $payments[:product][:post_edit]

    Stripe.api_key = ENV['STRIPE_API_KEY']

    token = post_payment_params[:stripe_token]
    email = post_payment_params[:email]
    post_id = params[:post_id]

    # Create the charge on Stripe's servers - this will charge the user's card
    begin
      charge = Stripe::Charge.create(
        amount: product[:price],
        currency: $payments[:currency],
        card: token,
        description: email
      )
    rescue Stripe::CardError => e
      logger.debug e
    end

    @post_payment = current_user.posts.find(post_id).post_payments.build(
      user_id: current_user.id,
      product_id: product[:id],
      email: email,
      amount: product[:price],
      currency: $payments[:currency],
      status: (charge.paid == true ? $payments[:status][:paid] : $payments[:status][:not_paid]),
      stripe_token: token,
      stripe_response: charge.to_json,
    )

    @post_payment.merge!(stripe_err_message: charge.failure_message, stripe_err_code: charge.failure_code) if (charge.failure_code && charge.failure_message)

    if @post_payment.save
      @post_payment.post.state_machine.transition_to(:paid)
    end

    respond_to do |format|
      if @post_payment.persisted?
        format.json { render json: @post_payment, status: :created, location: @post_payment  }
        format.html { redirect_to posts_path, notice: 'Success! Your post has been successfully submitted and an Editor will be assigned as soon as possible.' }
      else
        format.json { render json: @post_payment.errors, status: :unprocessable_entity }
        format.html { redirect_to edit_post_path(post_id), alert: 'Something went wrong with your payment. Please get send us a message at <a href="mailto:support@twitter">support@twitterpen</a>' }
      end
    end
  end

  private
    def post_payment_params
      params.require(:post_payment).permit(:stripe_token, :email)
    end
end

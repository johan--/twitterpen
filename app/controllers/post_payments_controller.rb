class PostPaymentsController < ApplicationController

  before_filter :authenticate_user!

  def create
    post = Post.for_user(current_user).find(params[:post_id])
    product = $payments[:product][:post_edit]

    unless current_user.is_publisher? && post.present?
      redirect_to root_path and return
    end

    # Create Stripe user if missing
    if current_user.stripe_customer_id.blank?
      current_user.stripe_customer(card_params[:stripe_token], post_payment_params[:email])
    end

    # Save the card on file as this is required every time we pass customer to stripe
    current_user.user_cards.create(card_params)

    # Create the charge on Stripe's servers - this will charge the user's card
    begin
      stripe_params = {
        amount: product[:price],
        currency: $payments[:currency],
        description: "Payment for POST ID #{post.id}",
      }

      stripe_params[:customer] = current_user.stripe_customer_id if current_user.stripe_customer_id?

      if params[:stripe_card_id].present?
        stripe_params[:card] = params[:stripe_card_id]
      else
        stripe_params[:card] = card_params[:stripe_card_id]
      end

      charge = Stripe::Charge.create(stripe_params)
    rescue Stripe::CardError => e
      logger.debug e
    end

    # Delete the card if required
    if post_payment_params.present? && post_payment_params[:save_card].blank?
      current_user.user_cards.last.destroy
    end

    # Create payment entry in our database
    post_payment = current_user.posts.find(post.id).post_payments.build(
      user_id:        current_user.id,
      product_id:     product[:id],
      email:          (post_payment_params.present? ? post_payment_params[:email] : 'cc_on_file'),
      amount:         product[:price],
      currency:       $payments[:currency],
      status:         (charge.paid == true ? $payments[:status][:paid] : $payments[:status][:not_paid]),
      stripe_token:   stripe_params[:card],
      stripe_response: charge.to_json,
    )

    post_payment.merge!(stripe_err_message: charge.failure_message, stripe_err_code: charge.failure_code) if (charge.failure_code && charge.failure_message)

    if post_payment.save
      post_payment.post.state_machine.transition_to(:paid)
    end

    respond_to do |format|
      if post_payment.persisted?
        format.json { render json: post_payment, status: :created, location: post_payment }
        format.html { redirect_to posts_path, notice: 'Success! You can now submit your post and an Editor will be assigned as soon as possible.' }
      else
        format.json { render json: post_payment.errors, status: :unprocessable_entity }
        format.html { redirect_to edit_post_path(post), alert: 'Something went wrong with your payment. Please send us a message at <a href="mailto:support@twitter">support@ghostpen.io</a>' }
      end
    end
  end

  def post_payment_params
    params.require(:post_payment).permit(:save_card, :email) if params[:post_payment]
  end

  def card_params
    params.require(:card).permit(
      :stripe_card_id, :stripe_fingerprint, :stripe_token,
      :name, :exp_month, :exp_year, :last4, :card_type,
    ) if params[:card]
  end

  private :post_payment_params, :card_params
end

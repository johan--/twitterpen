class PostPaymentsController < ApplicationController

  before_filter :authenticate_user!

  def create
    redirect_to edit_post_path(post_payment_params[:post_id]) and return

    amount = 50 # amount in cents
    currency = 'usd'

    Stripe.api_key = ENV['STRIPE_API_KEY']

    # Get the credit card details submitted by the form
    token = post_payment_params[:stripe_token]

    # Create the charge on Stripe's servers - this will charge the user's card
    begin
      charge = Stripe::Charge.create(
        amount: amount,
        currency: currency,
        card: token,
        description: post_payment_params[:email]
      )
    rescue Stripe::CardError => e
      logger.debug e
    end

    # @post_payment = current_user.posts.find(post_payment_params[:post_id]).post_payment.new do |p|
    #   p.email = post_payment_params[:email]
    #   p.amount = amount
    #   p.currency = currency
    #   p.stripe_token = token
    # end

    # respond_to do |format|
    #   if @post.save
    #     format.json { render json: @post_payment, status: :created, location: @post_payment }
    #     format.html { redirect_to posts_path }
    #   else
    #     format.json { render json: @post_payment.errors, status: :unprocessable_entity }
    #     format.html { redirect_to edit_post_path(post_payment_params[:post_id])}
    #   end
    # end
  end

  private
    def post_payment_params
      params.require(:post_payment).permit(:stripe_token, :email, :post_id)
    end
end

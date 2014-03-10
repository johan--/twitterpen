class Users::Stripe::CardsController < ApplicationController
  before_filter :authenticate_user!

  before_filter :check_stripe_customer, only: [:delete]

  def create
    if current_user.stripe_customer_id?
      customer = Stripe::Customer.retrieve(current_user.stripe_customer_id)
    else
      customer = Stripe::Customer.create(
        email: card_params[:email],
        card:  card_params[:stripe_token],
        description: current_user.id,
      )

      if customer.present?
        current_user.stripe_customer_id = customer.id
        current_user.save
      end
    end

    customer.cards.create(card: card_params[:stripe_token])

    redirect_to :back, notice: 'The card has been successfully added to your account!'
  end

  def update
  end

  def destroy
    card_id = params[:id]

    if card_id.present?
      customer = Stripe::Customer.retrieve(current_user.stripe_customer_id)
      resp = customer.cards.retrieve(card_id).delete()
      if resp[:deleted] == true
        redirect_to :back, notice: 'The card has been deleted successfully!' and return
      else
        redirect_to :back, alert: 'Something went wrong. We were unable to delete your card.' and return
      end
    end
  end

  private
    def card_params
      params.require(:card).permit('email', 'stripe_token') if params[:card]
    end

  protected
    def check_stripe_customer
      current_user.stripe_customer_id?
    end
end

class UsersController < ApplicationController
  before_filter :authenticate_user!

  def settings
    @section = 'settings'
    @edited_articles = Post.with_transition.where("post_transitions.to_state = 'completed'").count
    @card = current_user.user_cards.find_by_is_default(true)

    render 'users/publisher/settings'
  end

  def payment_history
    @section = 'settings'
    @post_payments = current_user.post_payments.ordered

    render 'users/publisher/payment_history'
  end
end

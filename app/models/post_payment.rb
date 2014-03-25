class PostPayment < ActiveRecord::Base
  belongs_to :user
  belongs_to :post
  belongs_to :card

  validates_presence_of :user, :post, :stripe_token

  scope :ordered, lambda { order('id DESC') }
end

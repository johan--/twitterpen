class PostPayment < ActiveRecord::Base
  belongs_to :user
  belongs_to :post

  validates_presence_of :user, :post, :stripe_token

  scope :ordered, lambda { order('id DESC') }
end

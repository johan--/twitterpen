class Post < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :user, :title, :body

  scope :ordered, lambda { order('created_at ASC') }
  scope :recently_updated, lambda { order('updated_at DESC') }
end

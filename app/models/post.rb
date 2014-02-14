class Post < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :user, :title, :body

  scope :ordered, order: "created_at ASC"
  scope :recently_updated, order: "updated_at DESC"
end

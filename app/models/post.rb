class Post < ActiveRecord::Base
  has_paper_trail only: [:title, :body]

  belongs_to :user

  has_many :post_payments
  has_many :post_transitions

  validates_presence_of :user, :title, :body

  scope :ordered, lambda { order('id ASC') }
  scope :recently_updated, lambda { order('updated_at DESC') }
  scope :for_user, lambda { |user| where(user_id: user.id) }

  # Initialize the state machine
  def state_machine
    @state_machine ||= PostStateMachine.new(self, transition_class: PostTransition)
  end

  # Optionally delegate some methods
  delegate :can_transition_to?, :transition_to!, :transition_to, :current_state,
           to: :state_machine
end

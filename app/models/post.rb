class Post < ActiveRecord::Base
  has_paper_trail only: [:title, :body]

  belongs_to :user

  has_many :post_payments
  has_many :post_transitions

  validates_presence_of :user, :title, :body

  scope :ordered, lambda { order('id ASC') }
  scope :recently_updated, lambda { order('updated_at DESC') }
  scope :for_user, lambda { |user| where(user_id: user.id) }
  scope :for_editor, lambda { |editor| where(editor_id: editor.id) }
  scope :with_transition, lambda {
    joins(:post_transitions)
    .where('post_transitions.sort_key = (SELECT MAX(sort_key) FROM post_transitions WHERE post_id = posts.id)')
    .select('posts.*, post_transitions.to_state, post_transitions.metadata, post_transitions.sort_key')
  }

  # Initialize the state machine
  def state_machine
    @state_machine ||= PostStateMachine.new(self, transition_class: PostTransition)
  end

  # Optionally delegate some methods
  delegate :can_transition_to?, :transition_to!, :transition_to, :current_state,
           to: :state_machine

  def editor_name
    User.find(self.editor_id).name if self.editor_id
  end
end

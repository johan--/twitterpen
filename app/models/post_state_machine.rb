class PostStateMachine
  include Statesman::Machine

  state :pending, initial: true
  state :paid
  state :assigned
  state :complete

  state :cancelled

  transition from: :pending,  to: [:paid, :cancelled]
  transition from: :paid,     to: [:assigned, :cancelled]
  transition from: :assigned, to: [:complete, :cancelled]

  guard_transition(to: :paid) do |post|
    post.post_payments.where(status: $payments[:status][:paid])
  end
end

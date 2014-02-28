class PostTransition < ActiveRecord::Base
  include Statesman::Adapters::ActiveRecordTransition

  belongs_to :post, inverse_of: :post_transitions
end

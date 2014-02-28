class CreatePostTransitions < ActiveRecord::Migration
  def change
    create_table :post_transitions do |t|
      t.string :to_state
      t.text :metadata, default: "{}"
      t.integer :sort_key
      t.integer :post_id
    end

    add_index :post_transitions, :post_id
    add_index :post_transitions, [:sort_key, :post_id], unique: true
  end
end

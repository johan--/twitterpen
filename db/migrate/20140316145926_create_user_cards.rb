class CreateUserCards < ActiveRecord::Migration
  def change
    create_table :user_cards do |t|
      t.integer :user_id
      t.string :stripe_card_id
      t.string :stripe_fingerprint
      t.string :stripe_token
      t.string :last4
      t.string :card_type
      t.integer :exp_month
      t.integer :exp_year
      t.string :name
      t.boolean :is_default
      t.boolean :is_active

      t.timestamps
    end

    add_index :user_cards, [:user_id, :stripe_fingerprint], unique: true
    add_index :user_cards, [:user_id, :is_active]
  end
end

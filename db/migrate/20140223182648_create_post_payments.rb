class CreatePostPayments < ActiveRecord::Migration
  def change
    create_table :post_payments do |t|
      t.integer :post_id
      t.integer :user_id
      t.integer :product_id
      t.string :email
      t.integer :amount
      t.string :currency
      t.integer :status
      t.string :stripe_token
      t.string :stripe_err_message
      t.string :stripe_err_code
      t.text :stripe_response

      t.timestamps
    end
  end
end

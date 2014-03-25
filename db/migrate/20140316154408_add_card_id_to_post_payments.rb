class AddCardIdToPostPayments < ActiveRecord::Migration
  def change
    add_column :post_payments, :card_id, :integer
  end
end

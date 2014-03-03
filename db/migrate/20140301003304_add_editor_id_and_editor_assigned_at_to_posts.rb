class AddEditorIdAndEditorAssignedAtToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :editor_id, :integer
    add_column :posts, :editor_assigned_at, :date

    add_index :posts, :user_id
    add_index :posts, :editor_id
  end
end

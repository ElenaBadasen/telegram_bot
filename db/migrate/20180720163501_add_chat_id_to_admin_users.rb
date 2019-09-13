class AddChatIdToAdminUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :admin_users, :chat_id, :string
  end
end

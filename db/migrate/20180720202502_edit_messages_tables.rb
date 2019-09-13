class EditMessagesTables < ActiveRecord::Migration[5.2]
  def change
    add_column :messages, :image_telegram_id, :string
    add_column :separate_messages, :is_suspended, :boolean
  end
end

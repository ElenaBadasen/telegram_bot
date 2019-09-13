class Tweaks < ActiveRecord::Migration[5.2]
  def change
    add_column :separate_messages, :is_queued, :boolean, default: false
    remove_column :messages, :log
    remove_column :messages, :test_log

    add_column :bots, :image_telegram_id, :string

    create_table :last_inline_buttons do |t|
      t.references :subscriber
      t.references :bot
      t.string :telegram_message_id

      t.timestamps
    end

    add_index :last_inline_buttons, [:subscriber_id, :bot_id], unique: true
  end
end

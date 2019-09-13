class CreateSubscribers < ActiveRecord::Migration[5.2]
  def change
    create_table :subscribers do |t|
      t.string :chat_id, null: false
      t.boolean :subscribed
      t.boolean :watch_first_day
      t.boolean :watch_second_day

      t.timestamps
    end

    add_index :subscribers, :chat_id, unique: true
    add_index :subscribers, :subscribed

    create_table :bots do |t|
      t.string :token, null: false
      t.string :name, null: false
      t.boolean :active
      t.boolean :is_test
      t.text :info

      t.timestamps
    end

    add_index :bots, :token, unique: true

    create_table :messages do |t|
      t.text :text
      t.boolean :is_send
      t.boolean :is_scheduled
      t.datetime :first_day_datetime
      t.datetime :second_day_datetime

      t.timestamps
    end

  end
end

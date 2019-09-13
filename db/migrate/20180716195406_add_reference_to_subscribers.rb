class AddReferenceToSubscribers < ActiveRecord::Migration[5.2]
  def change
    create_join_table :bots, :subscribers do |t|
      t.index [:bot_id, :subscriber_id]
    end

    add_column :messages, :log, :jsonb
    add_column :messages, :test_log, :jsonb
  end
end

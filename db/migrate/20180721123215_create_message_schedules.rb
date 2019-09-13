class CreateMessageSchedules < ActiveRecord::Migration[5.2]
  def change
    create_table :message_schedules do |t|
      t.text :plain_text

      t.timestamps
    end

    add_reference :messages, :message_schedule
  end
end

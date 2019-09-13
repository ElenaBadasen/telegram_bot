class EditMessages < ActiveRecord::Migration[5.2]
  def change
    remove_column :messages, :first_day_datetime
    rename_column :messages, :second_day_datetime, :scheduled_datetime
    add_column :messages, :separation, :string
  end
end
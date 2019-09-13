class AddPurposeToBot < ActiveRecord::Migration[5.2]
  def change
    add_column :bots, :purpose, :string

    remove_column :bots, :token
    remove_column :bots, :is_test

    create_table :separate_messages do |t|
      t.references :message
      t.references :bot
      t.boolean :is_send

      t.timestamps
    end

  end
end

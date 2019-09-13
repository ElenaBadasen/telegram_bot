class AddReferenceToSeparateMessage < ActiveRecord::Migration[5.2]
  def change
    add_reference :separate_messages, :subscriber
    add_column :separate_messages, :is_rejected, :boolean
  end
end

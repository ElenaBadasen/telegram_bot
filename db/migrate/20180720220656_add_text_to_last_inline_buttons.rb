class AddTextToLastInlineButtons < ActiveRecord::Migration[5.2]
  def change
    add_column :last_inline_buttons, :text, :text
  end
end

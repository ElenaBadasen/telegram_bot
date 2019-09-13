class RemoveSubscribedFromSubscribers < ActiveRecord::Migration[5.2]
  def change
    remove_column :subscribers, :subscribed
  end
end

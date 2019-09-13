ActiveAdmin.register Subscriber do
  permit_params :chat_id, :subscribed, :watch_first_day, :watch_second_day

  index do
    id_column
    column :chat_id
    column :subscribed do |resource|
      resource.bots.length > 0
    end
    column :watch_first_day
    column :watch_second_day
    column :created_at
    actions
  end
end
ActiveAdmin.register Message do
  permit_params :text, :is_send, :is_scheduled, :scheduled_datetime, :image, :separation

  index do
    selectable_column
    id_column
    column :text
    column :is_send
    column :is_scheduled
    column :scheduled_datetime
    column :created_at
    column :separation
    actions
  end

  show do
    attributes_table do
      row :text
      row :is_send
      row :is_scheduled
      row :scheduled_datetime
      row :image do |resource|
        if resource.image.attached?
          image_tag resource.image
        end
      end
      row :separation
      row :image_telegram_id
    end
  end

  form do |f|
    f.inputs 'Message params' do
      f.input :text
      f.input :is_send
      f.input :is_scheduled
      f.input :scheduled_datetime
      f.input :separation
      f.input :image, as: :file

      f.submit
    end
  end

  action_item :send_text, only: :show, :if => proc { !resource.is_scheduled && !resource.is_send && current_admin_user.role != 'tester' } do
    link_to 'Отправить', send_text_admin_message_path
  end

  member_action :send_text, method: :get do
    if current_admin_user.role == 'tester'
      redirect_to resource_path, alert: "Недостаточно прав для этого действия!"
    elsif resource.is_send
      redirect_to resource_path, notice: "Уже отправлено основному боту!"
    elsif resource.is_scheduled
      redirect_to resource_path, alert: "Нельзя вручную отправить сообщение, у которого задано время!"
    else
      resource.send_text
      redirect_to resource_path, notice: "Успешно отправлено основному боту!"
    end
  end

  action_item :send_text_test, only: :show do
    link_to 'Отправить тестовому боту', send_text_test_admin_message_path
  end

  member_action :send_text_test, method: :get do
    if resource.is_scheduled
      redirect_to resource_path, alert: "Нельзя вручную отправить сообщение, у которого задано время!"
    else
      resource.send_text_test
      redirect_to resource_path, notice: "Успешно отправлено тестовому боту!"
    end
  end
end
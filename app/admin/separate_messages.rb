ActiveAdmin.register SeparateMessage do
  actions :index, :show

  action_item :send_text, only: :show, :if => proc { !resource.is_send && (resource.bot.purpose == 'test' || current_admin_user.role != 'tester' ) } do
    link_to 'Отправить', send_text_admin_separate_message_path
  end

  member_action :send_text, method: :get do
    if current_admin_user.role == 'tester' && resource.bot.purpose != 'test'
      redirect_to resource_path, alert: "Недостаточно прав для этого действия!"
    elsif resource.is_send?
      redirect_to resource_path, notice: "Уже отправлено!"
    else
      if resource.send_now
        redirect_to resource_path, notice: "Успешно отправлено!"
      else
        redirect_to resource_path, alert: "Ошибка отправки, свяжитесь с администратором."
      end
    end
  end
end
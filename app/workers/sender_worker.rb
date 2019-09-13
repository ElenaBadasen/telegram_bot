class SenderWorker
  include Sidekiq::Worker

  def perform
    begin
      messages_to_process = Message.where(is_scheduled: true)
                                .where('scheduled_datetime < ? AND scheduled_datetime > ?', DateTime.now, 12.hours.ago)
      messages_to_process.each do |message|
        # чтобы ничего не отправилось два раза
        message.lock!
        if message.is_send
          message.update!(is_send: true)
          next
        end
        message.send_text_test
        message.send_text
        message.update!(is_send: true)
      end
    rescue => e
      Rails.logger.fatal("#catch_error_sidekiq SenderWorker #{e.message}")
      Rails.logger.fatal(e.backtrace)
      AdminUser.send_info_message("Sidekiq error happened: #{e.message}")
    end

    begin
      separate_messages_to_process = SeparateMessage.where(is_send: false, is_queued: false, is_suspended: false)
      separate_messages_to_process.each do |separate_message|
        # чтобы ничего не отправилось два раза
        separate_message.lock!
        if separate_message.is_queued || separate_message.is_send || separate_message.is_suspended
          separate_message.update!(is_send: separate_message.is_send)
          next
        end
        separate_message.update!(is_queued: true)
        SingleMessageSenderWorker.perform_async(separate_message.id)
      end
    rescue => e
      Rails.logger.fatal("#catch_error_sidekiq SenderWorker #{e.message}")
      Rails.logger.fatal(e.backtrace)
      AdminUser.send_info_message("Sidekiq error happened: #{e.message}")
    end
  end
end

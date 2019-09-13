class SingleMessageSenderWorker
  include Sidekiq::Worker

  def perform(separate_message_id)
    separate_message = SeparateMessage.find(separate_message_id)
    return unless separate_message.present?
    return if separate_message.is_send
    separate_message.send_now
  end
end

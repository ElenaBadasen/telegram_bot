# == Schema Information
#
# Table name: messages
#
#  id                  :bigint(8)        not null, primary key
#  text                :text
#  is_send             :boolean
#  is_scheduled        :boolean
#  scheduled_datetime  :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  separation          :string
#  image_telegram_id   :string
#  message_schedule_id :bigint(8)
#

class Message < ApplicationRecord
  has_one_attached :image
  has_many :separate_messages
  belongs_to :message_schedule, optional: true

  validate :datetime_presence

  def send_text(is_test: false)
    if is_test
      bot = Bot.test_bot
    else
      bot = Bot.normal_bot
    end
    subscribers = bot.subscribers
    if separation == 'first_day'
      subscribers = subscribers.first_day
    elsif separation == 'second_day'
      subscribers = subscribers.second_day
    end
    subscribers.each do |s|
      separate_message = SeparateMessage.create!(message: self, bot: bot, is_send: false, subscriber: s, is_rejected: false)
      SingleMessageSenderWorker.perform_async(separate_message.id)
    end
    unless is_test
      self.update!(is_send: true)
    end
  end

  def send_text_test
    send_text(is_test: true)
  end

  def datetime_presence
    if is_scheduled && !scheduled_datetime.present?
      errors.add(:scheduled_datetime, 'Должно быть указано для сообщений, отправляемых по графику')
    end
  end

  def self.check_unsend
    messages_to_process = Message.where(is_scheduled: true, is_send: false)
                              .where('scheduled_datetime < ?', 3.hours.ago)
    if messages_to_process.any?
      AdminUser.send_info_message("Unsend messages found: #{messages_to_process.map(&:id).join(', ')}")
    end

    separate_messages_to_process = SeparateMessage.where('is_send = false AND (created_at < ? OR is_suspended = true)', 3.hours.ago)
    if separate_messages_to_process.any?
      AdminUser.send_info_message("Unsend separate messages found: #{separate_messages_to_process.map(&:id).join(', ')}")
    end
  end

  def self.still_alive
    AdminUser.send_info_message('Still alive!')
  end
end

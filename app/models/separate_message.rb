# == Schema Information
#
# Table name: separate_messages
#
#  id            :bigint(8)        not null, primary key
#  message_id    :bigint(8)
#  bot_id        :bigint(8)
#  is_send       :boolean
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  subscriber_id :bigint(8)
#  is_rejected   :boolean
#  is_suspended  :boolean
#  is_queued     :boolean          default(FALSE)
#

class SeparateMessage < ApplicationRecord
  belongs_to :message
  belongs_to :bot
  belongs_to :subscriber

  include Rails.application.routes.url_helpers

  def send_now
    begin
      return if is_rejected
      unless bot.active && subscriber.bots.include?(bot)
        # у подписчика сейчас не подписан этот бот или бот вообще выключен, вычёркиваем
        self.update!(is_rejected: true)
        return
      end
      if message.separation == 'first_day' && !subscriber.watch_first_day || message.separation == 'second_day' && !subscriber.watch_second_day
        # подписчик не следит за этим днём, вычеркиваем
        self.update!(is_rejected: true)
        return
      end
      begin
        last_inline_button = subscriber.last_inline_buttons.find_by(bot_id: bot.id)
        if last_inline_button.present?
          last_inline_button.remove_buttons
        end
      rescue
        # тут некритично, если не сработает, в крайнем случае просто останутся кнопки, юзер переживёт
      end
      telegram_bot = bot.telegram_bot
      if message.image_telegram_id.present?
        begin
          telegram_bot.send_photo(chat_id: subscriber.chat_id, photo: message.image_telegram_id)
        rescue => e
          if e.message == 'Bad Request: Bad Request: wrong file identifier/HTTP URL specified' && message.image.attached?
            response = telegram_bot.send_photo(chat_id: subscriber.chat_id, photo: rails_blob_url(message.image, disposition: "attachment"))
            message.update!(image_telegram_id: response['result']['photo'].last['file_id'])
          end
        end
      elsif message.image.attached?
        response = telegram_bot.send_photo(chat_id: subscriber.chat_id, photo: rails_blob_url(message.image, disposition: "attachment"))
        message.update!(image_telegram_id: response['result']['photo'].last['file_id'])
      end
      response = telegram_bot.send_message(chat_id: subscriber.chat_id, text: message.text, reply_markup: SeparateMessage.default_keyboard)
      self.update!(is_send: true)
      begin
        if last_inline_button.present?
          last_inline_button.update!(text: message.text, telegram_message_id: response['result']['message_id'])
        else
          LastInlineButton.create!(text: message.text, telegram_message_id: response['result']['message_id'], subscriber: subscriber, bot: bot)
        end
      rescue
        # тоже некритично, в крайнем случае кнопки не удалятся в следующий раз
      end
      return true
    rescue => e
      Rails.logger.fatal("#message_suspended #{e.message}")
      Rails.logger.fatal(e.backtrace)
      AdminUser.send_info_message("Message suspended: #{self.id}")
      self.update!(is_suspended: true)
      return false
    end
  end

  def self.default_keyboard
    {inline_keyboard: [
        [
            {text: 'Настройки', callback_data: 'settings'},
            {text: 'Отписаться', callback_data: 'stop'}
        ],
        [
            {text: 'Info', callback_data: 'info'},
            {text: 'Полезные ссылки', callback_data: 'links'}
        ]
    ]}
  end
end

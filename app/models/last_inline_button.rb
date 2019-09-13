# == Schema Information
#
# Table name: last_inline_buttons
#
#  id                  :bigint(8)        not null, primary key
#  subscriber_id       :bigint(8)
#  bot_id              :bigint(8)
#  telegram_message_id :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  text                :text
#

class LastInlineButton < ApplicationRecord
  belongs_to :bot
  belongs_to :subscriber

  def remove_buttons
    if subscriber&.chat_id.present? && telegram_message_id.present? && text.present?
      bot.telegram_bot.edit_message_text(chat_id: subscriber.chat_id, message_id: telegram_message_id, text: text) rescue nil
    end
  end
end

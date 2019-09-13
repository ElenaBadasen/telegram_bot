# == Schema Information
#
# Table name: admin_users
#
#  id                     :bigint(8)        not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  chat_id                :string
#  role                   :string
#

class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, 
         :recoverable, :rememberable, :trackable, :validatable

  scope :with_chats, -> { where('chat_id IS NOT NULL') }

  def self.send_info_message(text)
    # тут отправляем синхронно, чтобы случайно не зависло в очереди сайдкика
    AdminUser.with_chats.each do |admin|
      Bot.test_bot.telegram_bot.send_message(chat_id: admin.chat_id, text: text) rescue nil
    end
  end
end

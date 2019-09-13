# == Schema Information
#
# Table name: subscribers
#
#  id               :bigint(8)        not null, primary key
#  chat_id          :string           not null
#  watch_first_day  :boolean
#  watch_second_day :boolean
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Subscriber < ApplicationRecord
  validates_uniqueness_of :chat_id

  scope :first_day, -> { where(watch_first_day: true) }
  scope :second_day, -> { where(watch_second_day: true) }

  has_and_belongs_to_many :bots
  has_many :separate_messages
  has_many :last_inline_buttons
end

# == Schema Information
#
# Table name: bots
#
#  id                :bigint(8)        not null, primary key
#  name              :string           not null
#  active            :boolean
#  info              :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  purpose           :string
#  image_telegram_id :string
#

class Bot < ApplicationRecord
  validates_presence_of :name
  validates_uniqueness_of :name

  has_and_belongs_to_many :subscribers
  has_many :separate_messages
  has_one_attached :image
  has_many :last_inline_buttons

  scope :active, -> { where(active: true) }

  def self.test_bot
    Bot.find_by(purpose: 'test')
  end

  def self.normal_bot
    Bot.find_by(purpose: 'normal')
  end

  def telegram_bot
    if purpose == 'test'
      Telegram.bots[:test_bot]
    elsif purpose == 'normal'
      Telegram.bots[:normal_bot]
    end
  end
end

# == Schema Information
#
# Table name: message_schedules
#
#  id         :bigint(8)        not null, primary key
#  plain_text :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class MessageSchedule < ApplicationRecord
  has_many :messages

  after_create :parse_data

  # структура:
  # выкладка или голосование или нет; к какому дню относится; макси или нет; текст; дата события
  def parse_data
    return if messages.length > 0
    Message.transaction do
      plain_text.split("\n").each do |string|
        data_array = string.split(';')
        next unless data_array[4].present?
        if data_array[1] == '1'
          separation = 'first_day'
        elsif data_array[1] == '2'
          separation = 'second_day'
        end
        text = data_array[3]
        if data_array[1] == '1'
          text += ' у команд первого дня.'
        elsif data_array[1] == '2'
          text += ' у команд второго дня.'
        end
        date = Time.parse(data_array[4]) + 10.hours
        if data_array[0] == 'выкладка'
          # нужны дополнительные напоминания и другой текст

          # в день самой выкладки
          main_text = 'Сегодня выкладка ' + text
          Message.create!(message_schedule: self, text: main_text, is_send: false, is_scheduled: true,
                          scheduled_datetime: date, separation: separation)

          # за день до
          day_before_text = 'Завтра выкладка ' + text
          Message.create!(message_schedule: self, text: day_before_text, is_send: false, is_scheduled: true,
                          scheduled_datetime: date - 1.day, separation: separation)

          if data_array[2] == 'макси'
            # ещё больше напоминаний
            # за неделю до
            # за день до
            week_before_text = 'Через неделю выкладка ' + text
            Message.create!(message_schedule: self, text: week_before_text, is_send: false, is_scheduled: true,
                            scheduled_datetime: date - 7.days, separation: separation)

            # за две недели до
            # за день до
            two_weeks_before_text = 'Через две недели выкладка  ' + text
            Message.create!(message_schedule: self, text: two_weeks_before_text, is_send: false, is_scheduled: true,
                            scheduled_datetime: date - 14.days, separation: separation)

          end
        elsif data_array[0] == 'начало голосования'
          vote_text = 'Сегодня начинается голосование за ' + text + '.'
          Message.create!(message_schedule: self, text: vote_text, is_send: false, is_scheduled: true,
                          scheduled_datetime: date)
        elsif data_array[0] == 'конец голосования'
          vote_text = 'Сегодня заканчивается голосование за ' + text + '.'
          Message.create!(message_schedule: self, text: vote_text, is_send: false, is_scheduled: true,
                          scheduled_datetime: date)
        else
          Message.create!(message_schedule: self, text: text, is_send: false, is_scheduled: true,
                          scheduled_datetime: date, separation: separation)
        end
      end
    end
  end
end

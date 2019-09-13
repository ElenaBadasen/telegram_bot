class MainTelegramController < Telegram::Bot::UpdatesController

  rescue_from StandardError do |e|
    Rails.logger.fatal("#catch_error_telegram #{e.message}")
    Rails.logger.fatal(e.backtrace)
    AdminUser.send_info_message("Telegram controller error happened: #{e.message}")
  end

  def bot_type
    # переопределяется
  end

  def connected_bot
    if bot_type == 'test'
      Bot.test_bot
    elsif bot_type == 'normal'
      Bot.normal_bot
    end
  end

  include Rails.application.routes.url_helpers

  def start!(data = nil, from_query: false)
    return unless connected_bot&.active
    # записываем айдишник юзера в список подключенных к боту
    string_chat_id = chat['id'].to_s
    subscriber = Subscriber.find_by(chat_id: string_chat_id)
    unless from_query
      remove_last_inline_button(subscriber, connected_bot)
    end
    if subscriber.present?
      subscriber.update!(watch_first_day: true, watch_second_day: true)
    else
      begin
        subscriber = Subscriber.create!(chat_id: string_chat_id, watch_first_day: true, watch_second_day: true)
      rescue ActiveRecord::RecordNotUnique
        # возможно где-то параллельно успел создаться, тогда найдём его и запишем туда
        subscriber = Subscriber.find_by(chat_id: string_chat_id)
        subscriber.update!(watch_first_day: true, watch_second_day: true)
      end
    end

    # и подписываем юзера на бота, если он ещё не подписан
    bot = connected_bot
    unless subscriber.bots.include?(bot)
      subscriber.bots << bot
    end
    if bot.image_telegram_id.present?
      bot.telegram_bot.send_photo(chat_id: subscriber.chat_id, photo: bot.image_telegram_id)
    elsif bot.image.attached?
      response = bot.telegram_bot.send_photo(chat_id: subscriber.chat_id, photo: rails_blob_url(bot.image, disposition: "attachment"))
      bot.update!(image_telegram_id: response['result']['photo'].last['file_id'])
    end
    response_for_buttons = respond_with :message, text: 'Добро пожаловать!', reply_markup: default_keyboard
    save_last_inline_button(response_for_buttons, subscriber, bot)
  end

  def stop!(from_query: false)
    return unless connected_bot&.active
    string_chat_id = chat['id'].to_s
    subscriber = Subscriber.find_by(chat_id: string_chat_id)
    unless from_query
      remove_last_inline_button(subscriber, connected_bot)
    end
    if subscriber.present?
      subscriber.update!(watch_first_day: false, watch_second_day: false)
      bot = connected_bot
      subscriber.bots -= [bot]
    end

    keyboard = {inline_keyboard: [[
        {text: 'Подписаться', callback_data: 'start'}
    ]]}
    response_for_buttons = respond_with :message, text: 'Бот выключен и больше не будет вам писать!', reply_markup: keyboard
    save_last_inline_button(response_for_buttons, subscriber, bot)
  end

  def callback_query(data)
    telegram_bot = connected_bot.telegram_bot
    retries_count = 0
    begin
      telegram_bot.answer_callback_query(callback_query_id: payload['id'])
    rescue => e
      if e.message == 'Bad Request: Bad Request: QUERY_ID_INVALID' && retries_count < 5
        retries_count += 1
        sleep 1
        retry
      else
        # raise
        # если этот ответ не пройдёт, ничего страшного не произойдёт, оно просто немного подумает и перестанет думать
      end
    end
    return unless connected_bot&.active
    telegram_bot.edit_message_text(chat_id: chat['id'].to_s, message_id: payload['message']['message_id'], text: payload['message']['text'])
    case data
      when 'info'
        info!(from_query: true)
      when 'settings'
        settings!(from_query: true)
      when 'stop'
        stop!(from_query: true)
      when 'start'
        start!(from_query: true)
      when 'first_day'
        first_day!(from_query: true)
      when 'second_day'
        second_day!(from_query: true)
      when 'both_days'
        both_days!(from_query: true)
      when 'cancel'
        cancel!(from_query: true)
      when 'links'
        links!
    end
  end

  def links!(from_query: false)
    return unless connected_bot&.active
    string_chat_id = chat['id'].to_s
    subscriber = Subscriber.find_by(chat_id: string_chat_id)
    unless from_query
      remove_last_inline_button(subscriber, connected_bot)
    end
    links_keyboard = {inline_keyboard:
      [
        [{text: 'Ссылка 1', url: 'https://ya.ru'}],
        [{text: 'Ссылка 2', url: 'https://ya.ru'}],
        [{text: 'Ссылка 3', url: 'https://ya.ru'}],
        [{text: 'Ссылка 4', url: 'https://ya.ru'}],
        [{text: 'Ссылка 5', url: 'https://ya.ru'}],
        [{text: 'Ссылка 6', url: 'https://ya.ru'}],
        [{text: 'Ссылка 7', url: 'https://ya.ru'}]
      ]
    }
    respond_with :message, text: 'Информация:', reply_markup: links_keyboard
    response_for_buttons = respond_with :message, text: 'Нажмите на одну из кнопок выше, чтобы перейти по ссылке.', reply_markup: default_keyboard
    save_last_inline_button(response_for_buttons, subscriber, connected_bot)
  end

  def help!(from_query: false)
    return unless connected_bot&.active
    info!(from_query: from_query)
  end

  def info!(from_query: false)
    return unless connected_bot&.active
    string_chat_id = chat['id'].to_s
    subscriber = Subscriber.find_by(chat_id: string_chat_id)
    unless from_query
      remove_last_inline_button(subscriber, connected_bot)
    end
    response_for_buttons = respond_with :message, text: connected_bot.info, reply_markup: default_keyboard
    save_last_inline_button(response_for_buttons, subscriber, connected_bot)
  end

  def first_day!(from_query: false)
    return unless connected_bot&.active
    string_chat_id = chat['id'].to_s
    subscriber = Subscriber.find_by(chat_id: string_chat_id)
    unless from_query
      remove_last_inline_button(subscriber, connected_bot)
    end
    if subscriber.present?
      subscriber.update!(watch_first_day: true, watch_second_day: false)
    end
    response_for_buttons = respond_with :message, text: 'Теперь вы будете получать напоминания о расписании первого дня. Эту настройку можно будет поменять в любое время.', reply_markup: default_keyboard
    save_last_inline_button(response_for_buttons, subscriber, connected_bot)
  end

  def second_day!(from_query: false)
    return unless connected_bot&.active
    string_chat_id = chat['id'].to_s
    subscriber = Subscriber.find_by(chat_id: string_chat_id)
    unless from_query
      remove_last_inline_button(subscriber, connected_bot)
    end
    if subscriber.present?
      subscriber.update!(watch_first_day: false, watch_second_day: true)
    end
    response_for_buttons = respond_with :message, text: 'Теперь вы будете получать напоминания о расписании второго дня. Эту настройку можно будет поменять в любое время.', reply_markup: default_keyboard
    save_last_inline_button(response_for_buttons, subscriber, connected_bot)
  end

  def both_days!(from_query: false)
    return unless connected_bot&.active
    string_chat_id = chat['id'].to_s
    subscriber = Subscriber.find_by(chat_id: string_chat_id)
    unless from_query
      remove_last_inline_button(subscriber, connected_bot)
    end
    if subscriber.present?
      subscriber.update!(watch_first_day: true, watch_second_day: true)
    end
    response_for_buttons = respond_with :message, text: 'Теперь вы будете получать напоминания о расписании и первого, и второго дня. Эту настройку можно будет поменять в любое время.', reply_markup: default_keyboard
    save_last_inline_button(response_for_buttons, subscriber, connected_bot)
  end

  def cancel!(from_query: false)
    return unless connected_bot&.active
    string_chat_id = chat['id'].to_s
    subscriber = Subscriber.find_by(chat_id: string_chat_id)
    unless from_query
      remove_last_inline_button(subscriber, connected_bot)
    end
    keyboard = default_keyboard
    response_for_buttons = respond_with :message, text: 'Настройки не изменились.', reply_markup: keyboard
    save_last_inline_button(response_for_buttons, subscriber, connected_bot)
  end

  def settings!(from_query: false)
    return unless connected_bot&.active
    string_chat_id = chat['id'].to_s
    subscriber = Subscriber.find_by(chat_id: string_chat_id)
    unless from_query
      remove_last_inline_button(subscriber, connected_bot)
    end
    keyboard = {inline_keyboard: [[
       {text: 'Первого дня', callback_data: 'first_day'},
       {text: 'Второго дня', callback_data: 'second_day'}],
       [{text: 'И то, и другое', callback_data: 'both_days'},
       {text: 'Отмена', callback_data: 'cancel'}
    ]]}
    response_for_buttons = respond_with :message, text: 'Выберите, какие напоминания вы хотите получать.', reply_markup: keyboard
    save_last_inline_button(response_for_buttons, subscriber, connected_bot)
  end

  def default_keyboard
    return unless connected_bot&.active
    SeparateMessage.default_keyboard
  end

  def remove_last_inline_button(subscriber, bot)
    begin
      last_inline_button = subscriber.last_inline_buttons.find_by(bot_id: bot.id)
      if last_inline_button.present?
        last_inline_button.remove_buttons
      end
    rescue
      # тут некритично, если не сработает, в крайнем случае просто останутся кнопки, юзер переживёт
    end
  end

  def save_last_inline_button(response_for_buttons, subscriber, bot)
    return unless response_for_buttons.present? && subscriber.present? && bot.present? && bot.active?
    begin
      last_inline_button = subscriber.last_inline_buttons.find_by(bot_id: bot.id)
      if last_inline_button.present?
        last_inline_button.update!(text: response_for_buttons['result']['text'], telegram_message_id: response_for_buttons['result']['message_id'])
      else
        LastInlineButton.create!(text: response_for_buttons['result']['text'], telegram_message_id: response_for_buttons['result']['message_id'], subscriber: subscriber, bot: bot)
      end
    rescue
      # некритично, если не сохранится, просто кнопки не удалятся в следующий раз
    end
  end
end
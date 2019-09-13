class WebhookManager
  def set_webhook(url, bot_type = 'test')
    if bot_type == 'test'
      test_bot = Telegram.bots[:test_bot]
      test_bot.set_webhook(url: url)
    else
      bot = Telegram.bots[:normal_bot]
      bot.set_webhook(url: url)
    end
  end
end
Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  root to: "admin/dashboard#index"

  telegram_webhook TelegramWebhookNormalController, :normal_bot
  telegram_webhook TelegramWebhookTestController, :test_bot

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

end

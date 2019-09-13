class ApplicationController < ActionController::Base
  protect_from_forgery prepend: true, with: :exception

  rescue_from StandardError do |e|
    Rails.logger.fatal("#catch_error #{e.message}")
    Rails.logger.fatal(e.backtrace)
    AdminUser.send_info_message("Error happened: #{e.message}")
  end
end

class ApplicationController < ActionController::Base
  before_action :basic
  protect_from_forgery with: :exception
  add_flash_types :success, :info, :warning, :danger

  helper_method :current_user, :logged_in?

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def logged_in?
    !current_user.nil?
  end

  private
  def basic
    authenticate_or_request_with_http_basic do |name, password|
      name == "eurus" && password == "eurus1234"
    end
  end
end

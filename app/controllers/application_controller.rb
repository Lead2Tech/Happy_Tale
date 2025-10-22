class ApplicationController < ActionController::Base
  before_action :set_host
  before_action :configure_permitted_parameters, if: :devise_controller?

  layout :layout_by_resource

  private

  # ✅ ここを追加：メール送信時のURL生成に必要
  def set_host
    Rails.application.routes.default_url_options[:host] = request.host_with_port
  end

  def layout_by_resource
    if devise_controller?
      "devise"
    else
      "application"
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :nickname])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :nickname])
  end
end

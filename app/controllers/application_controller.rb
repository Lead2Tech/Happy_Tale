class ApplicationController < ActionController::Base
  layout "application"  # ✅ Devise専用レイアウトを避ける
  before_action :set_host
  before_action :configure_permitted_parameters, if: :devise_controller?

  private

  # ✅ メール送信時のURL生成に必要
  def set_host
    Rails.application.routes.default_url_options[:host] = request.host_with_port
  end

  protected

  # ✅ Deviseの許可パラメータ設定
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :nickname])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :nickname])
  end

  # ✅ ログイン後の遷移先（例：日記一覧ページ）
  def after_sign_in_path_for(resource)
    diaries_path
  end

  # ✅ ログアウト後の遷移先（例：トップページ）
  def after_sign_out_path_for(resource_or_scope)
    root_path
  end
end

require_relative "boot"
require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module HappyTale
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    config.i18n.default_locale = :ja

    # lib配下のautoload設定
    config.autoload_lib(ignore: %w(assets tasks))

    # URL生成時のデフォルトホストを設定（開発環境用）
    Rails.application.routes.default_url_options[:host] = 'localhost:3000'
  end
end

# ✅ 環境変数を読み込む（ここが大事！Applicationクラスの外）
Dotenv::Railtie.load if defined?(Dotenv)

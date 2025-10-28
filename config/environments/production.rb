# config/environments/production.rb

require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # ✅ コードは本番ではリロードしない
  config.enable_reloading = false

  # ✅ 起動時に全コードを読み込む
  config.eager_load = true

  # ✅ エラーレポートは無効化し、キャッシュを有効化
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  # ✅ マスターキー必須（Renderでは自動処理される）
  # config.require_master_key = true

  # ✅ 静的ファイルをRailsから配信（Render対応）
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present? || ENV['RENDER'].present?

  # ✅ CSS圧縮（必要に応じて）
  # config.assets.css_compressor = :sass

  # ✅ プリコンパイル済みアセット以外は使用しない
  config.assets.compile = false

  # ✅ 画像・CSS・JSのCDN配信設定（未使用ならコメントのままでOK）
  # config.asset_host = "https://assets.happy-tale.onrender.com"

  # ✅ ファイル送信ヘッダ（Renderでは基本不要）
  # config.action_dispatch.x_sendfile_header = "X-Accel-Redirect"

  # ✅ アップロードファイルはローカル保存
  config.active_storage.service = :local

  # ✅ SSLを強制（HTTPS）
  config.force_ssl = true

  # ✅ ログ設定
  config.logger = ActiveSupport::Logger.new(STDOUT)
    .tap  { |logger| logger.formatter = ::Logger::Formatter.new }
    .then { |logger| ActiveSupport::TaggedLogging.new(logger) }

  config.log_tags = [ :request_id ]
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # ✅ メールキャッシュは無効
  config.action_mailer.perform_caching = false

  # ✅ 国際化：翻訳がない場合はデフォルトロケールを使う
  config.i18n.fallbacks = true

  # ✅ 非推奨警告はログ出力しない
  config.active_support.report_deprecations = false

  # ✅ マイグレーション後にスキーマをダンプしない
  config.active_record.dump_schema_after_migration = false

  # ✅ DNSリバインディング対策（デフォルトで十分）
  # config.hosts << "happy-tale.onrender.com"

  # ✅ メールURL生成用設定
  config.action_mailer.default_url_options = {
    host: 'happy-tale.onrender.com',
    protocol: 'https'
  }

  # ✅ キャッシュストア（必要に応じて有効化）
  # config.cache_store = :memory_store

  # ✅ Active Jobキューアダプタ（不要ならコメント）
  # config.active_job.queue_adapter = :async
end

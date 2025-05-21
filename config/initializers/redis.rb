redis_url = {
  development: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"),
  test: ENV.fetch("REDIS_TEST_URL", "redis://localhost:6380/0"),
  production: ENV.fetch("REDIS_URL")
}

$redis = Redis.new(
  url: redis_url[Rails.env.to_sym],
  ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
)

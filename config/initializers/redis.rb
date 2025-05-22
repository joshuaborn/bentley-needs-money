if ENV.include?("REDIS_URL") or ENV.include?("REDIS_TEST_URL")
  redis_url = {
    development: ENV.fetch("REDIS_URL"),
    test: ENV.fetch("REDIS_TEST_URL"),
    production: ENV.fetch("REDIS_URL")
  }

  $redis = ConnectionPool::Wrapper.new do
    Redis.new(
      url: redis_url[Rails.env.to_sym],
      ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
    )
  end
end

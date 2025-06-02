class YnabService
  class YnabServiceError < StandardError; end
  class ArgumentError < YnabServiceError; end
  class InitializationError < YnabServiceError; end

  def initialize(person)
    raise ArgumentError, "There must be a currently logged-in person." if person.nil?
    raise ArgumentError, "Parameter to YnabService must be a Person record." unless person.kind_of?(Person)

    @person = person
    @conn = Faraday.new(url: "https://app.ynab.com") do |builder|
      builder.request :json
      builder.response :json
      builder.response :raise_error
      builder.response :logger if Rails.env.development?
    end
  end

  def request_access_tokens(redirect_uri, code)
    raise ArgumentError, "The redirect URI cannot be blank." if redirect_uri.blank?
    raise ArgumentError, "The authorization code cannot be blank." if code.blank?
    if Rails.application.credentials.ynab_client_id.blank? or
       Rails.application.credentials.ynab_client_secret.blank?
      raise InitializationError,
        "Credentials for the application to authenticate users with YNAB are not available."
    end

    $redis.set(
      "person:#{@person.id}:ynab:authorization_code",
      $lockbox.encrypt(code)
    )

    response = @conn.post(
      "/oauth/token",
      client_id: Rails.application.credentials.ynab_client_id,
      client_secret: Rails.application.credentials.ynab_client_secret,
      redirect_uri: redirect_uri,
      grant_type: "authorization_code",
      code: code
    )

    set_access_tokens response.body

    ServiceResult.success("Successfully connected to YNAB!")

  rescue ArgumentError => e
    Rails.logger.warn "YNAB authorization failed - invalid parameters: #{e.message}"
    ServiceResult.failure("Invalid authorization parameters. Please try connecting again.")

  rescue InitializationError => e
    Rails.logger.error "YNAB authorization failed - configuration error: #{e.message}"
    ServiceResult.failure("We're experiencing technical difficulties. Please try again later.")

  rescue Faraday::UnauthorizedError, Faraday::ForbiddenError => e
    Rails.logger.error "YNAB authorization failed - authentication rejected: #{e.message}"
    ServiceResult.failure("Authorization failed. Please try connecting again.")

  rescue Faraday::BadRequestError => e
    Rails.logger.warn "YNAB authorization failed - bad request: #{e.message}"
    ServiceResult.failure("Invalid authorization code. Please try connecting again.")

  rescue Faraday::TooManyRequestsError => e
    Rails.logger.warn "YNAB authorization failed - rate limited: #{e.message}"
    ServiceResult.failure("Too many requests. Please try again in a few minutes.")

  rescue Faraday::ServerError => e
    Rails.logger.error "YNAB authorization failed - server error: #{e.message}"
    ServiceResult.failure("YNAB is experiencing issues. Please try again later.")

  rescue Faraday::ConnectionFailed, Faraday::TimeoutError, Faraday::SSLError => e
    Rails.logger.error "YNAB authorization failed - network error: #{e.message}"
    ServiceResult.failure("Connection failed. Please check your internet connection and try again.")

  rescue StandardError => e
    Rails.logger.error "YNAB authorization failed - unexpected error: #{e.class} - #{e.message}"
    ServiceResult.failure("An unexpected error occurred. Please try again.")
  end

  def request_transactions
    make_authenticated_request("transactions", :get, "/api/v1/budgets/default/transactions") do |response|
      ServiceResult.success("Successfully fetched transactions from YNAB.", response.body)
    end
  rescue StandardError => e
    Rails.logger.error "YNAB API call failed: #{e.class} - #{e.message}"
    ServiceResult.failure("Failed to fetch budgets from YNAB.")
  end

  private

  def make_authenticated_request(operation_name, method, path, **options)
    access_token = get_access_token
    if access_token.nil? and get_refresh_token.nil?
      Rails.logger.warn "YNAB API call failed - no access token available"
      return ServiceResult.failure("No YNAB connection available. Please connect to YNAB first.")
    end

    response = @conn.public_send(method, path, **options) do |req|
      req.headers["Authorization"] = "Bearer #{access_token}"
    end
    yield(response)
  end

  def set_access_tokens(parameters)
    $redis.pipelined do |pipeline|
      if parameters["expires_in"]
        pipeline.setex(
          "person:#{@person.id}:ynab:access_token",
          parameters["expires_in"],
          $lockbox.encrypt(parameters["access_token"])
        )
      else
        pipeline.set(
          "person:#{@person.id}:ynab:access_token",
          $lockbox.encrypt(parameters["access_token"])
        )
      end
      if parameters["refresh_token"]
        pipeline.set(
          "person:#{@person.id}:ynab:refresh_token",
          $lockbox.encrypt(parameters["refresh_token"])
        )
      end
    end
  end

  def get_access_token
    encrypted_token = $redis.get("person:#{@person.id}:ynab:access_token")
    return nil if encrypted_token.nil?

    $lockbox.decrypt(encrypted_token)
  end

  def get_refresh_token
    encrypted_token = $redis.get("person:#{@person.id}:ynab:refresh_token")
    return nil if encrypted_token.nil?

    $lockbox.decrypt(encrypted_token)
  end
end

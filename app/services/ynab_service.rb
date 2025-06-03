class YnabService
  class YnabServiceError < StandardError; end
  class ArgumentError < YnabServiceError; end
  class InitializationError < YnabServiceError; end

  def initialize(person)
    raise ArgumentError, "There must be a currently logged-in person." if person.nil?
    raise ArgumentError, "Parameter to YnabService must be a Person record." unless person.kind_of?(Person)

    @person = person
    @connection = Faraday.new(url: "https://api.ynab.com") do |builder|
      builder.request :authorization, "Bearer", -> { get_access_token }
      builder.request :json
      builder.response :json
      builder.response :raise_error
      builder.response :logger if Rails.env.development?
    end

    self
  end

  def request_access_tokens(redirect_uri, code)
    raise ArgumentError, "The redirect URI cannot be blank." if redirect_uri.blank?
    raise ArgumentError, "The authorization code cannot be blank." if code.blank?
    if Rails.application.credentials.ynab_client_id.blank? or
       Rails.application.credentials.ynab_client_secret.blank?
      raise InitializationError,
        "Credentials for the application to authenticate users with YNAB are not available."
    end

    with_error_handling("authorization") do
      $redis.set(
        "person:#{@person.id}:ynab:authorization_code",
        $lockbox.encrypt(code)
      )

      oauth_connection = Faraday.new(url: "https://app.ynab.com") do |builder|
        builder.request :json
        builder.response :json
        builder.response :raise_error
        builder.response :logger if Rails.env.development?
      end

      response = oauth_connection.post(
        "/oauth/token",
        client_id: Rails.application.credentials.ynab_client_id,
        client_secret: Rails.application.credentials.ynab_client_secret,
        redirect_uri: redirect_uri,
        grant_type: "authorization_code",
        code: code
      )

      set_access_tokens response.body
      ServiceResult.success("Successfully connected to YNAB!")
    end
  rescue ArgumentError => e
    Rails.logger.warn "YNAB authorization failed - invalid parameters: #{e.message}"
    ServiceResult.failure("Invalid authorization parameters. Please try connecting again.")

  rescue InitializationError => e
    Rails.logger.error "YNAB authorization failed - configuration error: #{e.message}"
    ServiceResult.failure("We're experiencing technical difficulties. Please try again later.")
  end

  def request_transactions
    make_authenticated_request("transactions", :get, "/v1/budgets/default/transactions") do |response|
      Rails.logger.info ""
      Rails.logger.info "REQUEST TRANSACTIONS"
      Rails.logger.info ""
      Rails.logger.info response
      ServiceResult.success("Successfully fetched transactions from YNAB.", response.body)
    end
  end

  def get_access_token
    encrypted_token = $redis.get("person:#{@person.id}:ynab:access_token")
    return nil if encrypted_token.nil?

    $lockbox.decrypt(encrypted_token)
  end

  private

  def make_authenticated_request(operation_name, method, path, **options)
    access_token = get_access_token
    if access_token.nil? and get_refresh_token.nil?
      Rails.logger.warn "YNAB API call failed - no access token available"
      return ServiceResult.failure("No YNAB connection available. Please connect to YNAB first.")
    end

    with_error_handling(operation_name) do
      response = @connection.public_send(method, path, **options)
      yield(response)
    end
  end

  def with_error_handling(operation_name)
    yield
  rescue Faraday::UnauthorizedError => e
    Rails.logger.error "YNAB #{operation_name} failed - authentication rejected: #{e.message}"
    ServiceResult.failure("Your YNAB connection has expired. Please reconnect to YNAB.")

  rescue Faraday::ForbiddenError => e
    Rails.logger.error "YNAB #{operation_name} failed - access forbidden: #{e.message}"
    ServiceResult.failure("Access denied. Please check your YNAB permissions and reconnect.")

  rescue Faraday::BadRequestError => e
    Rails.logger.warn "YNAB #{operation_name} failed - bad request: #{e.message}"
    ServiceResult.failure("Invalid request. Please reconnect to YNAB.")

  rescue Faraday::TooManyRequestsError => e
    Rails.logger.warn "YNAB #{operation_name} failed - rate limited: #{e.message}"
    ServiceResult.failure("Too many requests. Please try again in a few minutes.")

  rescue Faraday::ConnectionFailed, Faraday::TimeoutError, Faraday::SSLError => e
    Rails.logger.error "YNAB #{operation_name} failed - network error: #{e.message}"
    ServiceResult.failure("Connection failed. Please check your internet connection and try again.")

  rescue Faraday::ServerError => e
    Rails.logger.error "YNAB #{operation_name} failed - server error: #{e.message}"
    ServiceResult.failure("YNAB is experiencing issues. Please try again later.")

  rescue JSON::ParserError => e
    Rails.logger.error "YNAB #{operation_name} failed - invalid JSON response: #{e.message}"
    ServiceResult.failure("We're experiencing technical difficulties. Please try again later.")

  rescue StandardError => e
    Rails.logger.error "YNAB #{operation_name} failed - unexpected error: #{e.class} - #{e.message}"
    ServiceResult.failure("An unexpected error occurred. Please try again later.")
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

  def get_refresh_token
    encrypted_token = $redis.get("person:#{@person.id}:ynab:refresh_token")
    return nil if encrypted_token.nil?

    $lockbox.decrypt(encrypted_token)
  end
end

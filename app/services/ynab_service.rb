class YnabService
  class YnabServiceError < StandardError; end
  class ArgumentError < YnabServiceError; end
  class InitializationError < YnabServiceError; end

  def initialize(person)
    raise ArgumentError, "There must be a currently logged-in person." if person.blank?

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
  end

  private

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
end

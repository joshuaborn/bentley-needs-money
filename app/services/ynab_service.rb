class YnabService
  def initialize(person)
    @person = person
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
end

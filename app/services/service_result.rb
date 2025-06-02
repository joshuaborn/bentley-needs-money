class ServiceResult
  attr_reader :message, :success, :payload

  def initialize(success, message, payload = nil)
    @success = success
    @message = message
    @payload = payload
  end

  def self.success(message, payload = nil)
    new(true, message, payload)
  end

  def self.failure(message)
    new(false, message)
  end

  def success?
    @success
  end

  def failure?
    !@success
  end
end

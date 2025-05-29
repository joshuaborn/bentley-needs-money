class ServiceResult
  attr_reader :message, :success

  def initialize(success, message)
    @success = success
    @message = message
  end

  def self.success(message)
    new(true, message)
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

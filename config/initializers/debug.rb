if Rails.env.development?
  require "debug/session"
  Rails.logger.info "Starting debug session"
  DEBUGGER__.open(port: "12345", host: "0.0.0.0")
end

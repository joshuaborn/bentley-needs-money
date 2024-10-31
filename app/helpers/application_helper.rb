module ApplicationHelper
  def bulma_notification_name(rails_name)
    hash_map = {
      notice: "info",
      alert: "warning",
      error: "danger"
    }
    if hash_map.has_key?(rails_name.to_sym)
      hash_map[rails_name.to_sym]
    else
      rails_name
    end
  end
end

require 'rails_helper'

RSpec.describe ApplicationHelper, type: :view do
  describe ".bulma_notification_name" do
    it "translates Rails' flash names to Bulma's notification names" do
      expect(bulma_notification_name('notice')).to eq('info')
      expect(bulma_notification_name('alert')).to eq('warning')
      expect(bulma_notification_name('error')).to eq('danger')
    end

    it "leaves Bulma's notification names as is " do
      expect(bulma_notification_name('info')).to eq('info')
      expect(bulma_notification_name('warning')).to eq('warning')
      expect(bulma_notification_name('danger')).to eq('danger')
    end
  end
end

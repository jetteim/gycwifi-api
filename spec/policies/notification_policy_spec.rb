require 'rails_helper'

describe NotificationPolicy do
  subject { described_class.new(user, notification) }

  let(:user) { create(:user) }
  let(:notification) { create(:notification) }

  context 'user can create notification' do
    it { is_expected.to permit_new_and_create_actions }
  end
end

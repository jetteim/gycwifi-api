require 'rails_helper'

describe OpinionPolicy do
  subject { described_class.new(user, opinion) }

  let(:user) { create(:user) }
  let(:opinion) { create(:opinion) }

  context 'user can create notification' do
    it { is_expected.to permit_action(:create) }
  end
end

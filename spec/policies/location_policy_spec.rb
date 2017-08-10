require 'rails_helper'

describe LocationPolicy do
  subject { described_class.new(user, location) }

  let(:user) { create(:user) }
  let(:location) { create(:location) }

  context 'create' do
    context 'user can create location' do
      it { is_expected.to permit_action(:create) }
    end
    context 'free user can`t create > 3 locations' do
      before { create_list(:location, 3, user: user) }
      it { is_expected.to forbid_action(:create) }
    end
    context 'pro user can`t create > 6 locations' do
      let(:user) { create(:user, :pro) }

      before { create_list(:location, 6, user: user) }
      it { is_expected.to forbid_action(:create) }
    end
    context 'exclusive user can`t create > 16 locations' do
      let(:user) { create(:user, :exclusive) }

      before { create_list(:location, 16, user: user) }
      it { is_expected.to forbid_action(:create) }
    end
  end
end

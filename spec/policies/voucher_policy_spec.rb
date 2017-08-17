require 'rails_helper'

describe VoucherPolicy do
  subject { described_class.new(user, voucher) }

  let(:user) { create(:user) }
  let(:location) { create(:location, user: user) }
  let!(:voucher) { create(:voucher, location: location) }

  context 'author scope' do
    it { expect(described_class::Scope.new(user, Voucher.all).resolve).to include(voucher) }
  end

  context 'foreign user scope' do
    let(:foreign_user) { create(:user) }

    it { expect(described_class::Scope.new(foreign_user, Voucher.all).resolve).not_to include(voucher) }
  end

  context 'power user can show edit destroy voucher' do
    let(:user) { create(:user, :power_user) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:destroy) }
  end

  context 'author user can show edit destroy voucher' do
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:destroy) }
  end
end

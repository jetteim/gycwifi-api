require 'rails_helper'

describe BrandPolicy do
  subject { described_class.new(user, brand) }

  let(:resolved_scope) { described_class::Scope.new(user, Brand.all).resolve }
  let(:user) { create(:user) }
  let(:brand) { create(:brand) }
  let(:public_brand) { create(:brand, public: true) }

  context 'free user can`t create brand' do
    it { is_expected.to forbid_action(:create) }
  end

  context 'free user can see public brands' do
    it { expect(resolved_scope).to include(public_brand) }
    it { expect(resolved_scope).not_to include(brand) }
  end

  context 'super_user can everything' do
    let(:user) { create(:user, :super_user) }

    it { is_expected.to permit_actions(%i[index show create update destroy]) }
    it { expect(resolved_scope).to include(public_brand, brand) }
  end

  context 'exclusive user can`t create > 6 brands' do
    let(:user) { create(:user, :exclusive) }

    before { create_list(:brand, 6, user: user) }
    it { is_expected.to forbid_action(:create) }
  end

  context 'pro user can`t create > 3 brands' do
    let(:user) { create(:user, :pro) }

    before { create_list(:brand, 3, user: user) }
    it { is_expected.to forbid_action(:create) }
  end

  context 'user can update, destroy and show his own brand' do
    let(:user) { brand.user }

    it { is_expected.to permit_actions(%i[show update destroy]) }
  end

  context 'operator can manage child user`s brands' do
    let(:user) { create(:user, :operator) }

    before do
      child = brand.user
      child.user = user
      child.save!
    end
    it { is_expected.to permit_actions(%i[show update destroy]) }
  end
end

require 'rails_helper'

describe BrandPolicy do
  subject { described_class.new(user, brand) }

  let(:resolved_scope) { described_class::Scope.new(user, Brand.all).resolve }
  let(:user) { create(:user) }
  let(:brand) { create(:brand) }
  let(:public_brand) { create(:brand, public: true) }

  context 'free user can`t create brand' do
    it { is_expected.to forbid_new_and_create_actions }
  end

  context 'free user can see public brands' do
    it { expect(resolved_scope).to include(public_brand) }
    it { expect(resolved_scope).not_to include(brand) }
  end

  context 'super_user can everything' do
    let(:user) { create(:user, :super_user) }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_new_and_create_actions }
    it { is_expected.to permit_edit_and_update_actions }
    it { is_expected.to permit_action(:destroy) }
    it { expect(resolved_scope).to include(public_brand, brand) }
  end

  context 'exclusive user can create > 5 brands' do
    let(:user) { create(:user, :exclusive) }
    before { create_list(:brand, 5, user: user) }

    it { is_expected.to permit_new_and_create_actions }
  end

  context 'exclusive user can`t create > 6 brands' do
    let(:user) { create(:user, :exclusive) }
    before { create_list(:brand, 6, user: user) }

    it { is_expected.to forbid_new_and_create_actions }
  end

  context 'pro user can create > 2 brands' do
    let(:user) { create(:user, :pro) }
    before { create_list(:brand, 2, user: user) }

    it { is_expected.to permit_new_and_create_actions }
  end

  context 'pro user can`t create > 3 brands' do
    let(:user) { create(:user, :pro) }
    before { create_list(:brand, 3, user: user) }

    it { is_expected.to forbid_new_and_create_actions }
  end

  context 'user can update, destroy and show his own brand' do
    let(:user) { brand.user }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_edit_and_update_actions }
    it { is_expected.to permit_action(:destroy) }
  end

  context 'operator can manage child user`s brands' do
    let(:user) { create(:user, :operator) }
    before do
      child = brand.user
      child.user = user
      child.save!
    end

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_edit_and_update_actions }
    it { is_expected.to permit_action(:destroy) }
  end
end

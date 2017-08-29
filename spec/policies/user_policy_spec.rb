require 'rails_helper'

describe UserPolicy do
  subject { described_class.new(user, child_user) }

  let(:user) { create(:user) }
  let(:child_user) { create(:user, user: user) }

  context 'parent user can manage child' do
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_edit_and_update_actions }
    it { is_expected.to permit_action(:destroy) }
  end

  context 'child can`t manage parent' do
    it { expect(described_class.new(child_user, user)).to forbid_action(:show) }
    it { expect(described_class.new(child_user, user)).to forbid_edit_and_update_actions }
    it { expect(described_class.new(child_user, user)).to forbid_action(:destroy) }
  end

  context 'user can`t manage peers' do
    let(:manager) { create(:user, :admin) }
    let(:user) { create(:user, user: manager) }
    let(:peer) { create(:user, user: manager) }
    it { expect(described_class.new(user, peer)).to forbid_edit_and_update_actions }
  end

  context 'power user can create user' do
    let(:user) { create(:user, :power_user) }

    it { is_expected.to permit_new_and_create_actions }
  end
end

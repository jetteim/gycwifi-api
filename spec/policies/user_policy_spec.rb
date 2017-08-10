require 'rails_helper'

describe UserPolicy do
  subject { described_class.new(user, child_user) }

  let(:user) { create(:user) }
  let(:child_user) { create(:user, user: user) }

  context 'parent user can manage child' do
    it { is_expected.to permit_actions(%i[show update destroy]) }
  end
  context 'child can`t manage parent' do
    it { expect(described_class.new(child_user, user)).to forbid_actions(%i[show update destroy]) }
  end
  context 'power user can create user' do
    let(:user) { create(:user, :power_user) }

    it { is_expected.to permit_action(:create) }
  end
end

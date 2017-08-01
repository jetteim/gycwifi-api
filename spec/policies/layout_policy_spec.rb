require 'rails_helper'

describe LayoutPolicy do
  subject { described_class.new(user, layout) }

  let(:resolved_scope) { described_class::Scope.new(user, Layout.all).resolve }
  let(:user) { create(:user) }
  let(:layout) { create(:layout) }

  context 'admin can everything' do
    let(:user) { create(:user, :super_user) }

    it { is_expected.to permit_actions(%i[show create update destroy]) }
  end
  context 'user can`t create or show layout' do
    it { is_expected.to forbid_actions(%i[create show]) }
  end
  context 'user can see layout' do
    it { expect(resolved_scope).to include(layout) }
  end
end

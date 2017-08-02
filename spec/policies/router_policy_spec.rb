require 'rails_helper'

describe RouterPolicy do
  subject { described_class.new(user, router) }

  let(:resolved_scope) { described_class::Scope.new(user, Router.all).resolve }
  let(:user) { create(:user) }
  let(:router) { create(:router) }

  context 'create' do
    it { is_expected.to permit_action(:create) }

    context 'free user can`t create > 5 routers' do
      before { create_list(:router, 5, user: user) }

      it { is_expected.to forbid_action(:create) }
    end

    context 'pro user can`t create > 16 routers' do
      let(:user) { create(:user, :pro) }

      before { create_list(:router, 16, user: user) }

      it { is_expected.to forbid_action(:create) }
    end
  end
end

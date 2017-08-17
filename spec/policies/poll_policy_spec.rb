require 'rails_helper'

describe PollPolicy do
  subject { described_class.new(user, poll) }

  let(:resolved_scope) { described_class::Scope.new(user, Poll.all).resolve }
  let(:poll) { create(:poll) }

  context 'admin can everything' do
    let(:user) { create(:user, :admin) }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_new_and_create_actions }
    it { is_expected.to permit_edit_and_update_actions }
    it { is_expected.to permit_action(:destroy) }
  end

  context 'user can`t see another`s poll' do
    let(:user) { create(:user) }

    it { expect(resolved_scope).not_to include(poll) }
  end

  context 'creator can do everything with his own poll' do
    context 'Index' do
      let(:poll) { Poll }
      let(:user_poll) { create(:poll) }
      let(:user) { user_poll.user }

      it { is_expected.to permit_action(:index) }
      it { expect(resolved_scope).to include(user_poll) }
    end

    context 'create destroy show' do
      let(:user) { poll.user }

      it { is_expected.to permit_action(:show) }
      it { is_expected.to permit_new_and_create_actions }
      it { is_expected.to permit_edit_and_update_actions }
      it { is_expected.to permit_action(:destroy) }
    end
  end

  context 'free user can`t create > 3 polls' do
    let(:user) { create(:user) }

    before { create_list(:poll, 3, user: user) }

    it { is_expected.to forbid_new_and_create_actions }
  end

  context 'pro user can`t create > 11 polls' do
    let(:user) { create(:user, :pro) }

    before { create_list(:poll, 11, user: user) }

    it { is_expected.to forbid_new_and_create_actions }
  end

  context 'employee can view owner polls' do
    let(:user) { create(:user, :employee, user: owner) }
    let(:poll) { create(:poll, user: owner) }
    let(:owner) { create(:user, :admin) }

    it { is_expected.to permit_action(:show) }
  end

  context 'manager can view child items' do
    let(:user) { create(:user, :manager) }
    let(:child) { create(:user, :admin, user: user) }
    let(:poll) { create(:poll, user: child) }

    it { is_expected.to permit_action(:show) }
  end
end

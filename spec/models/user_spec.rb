# == Schema Information
#
# Table name: users
#
#  id            :integer          not null, primary key
#  username      :string           not null
#  email         :string           not null
#  password      :string           not null
#  avatar        :string           default("/images/avatars/default.jpg")
#  type          :string           default("FreeUser"), not null
#  tour          :boolean          default(TRUE), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  lang          :string           default("ru")
#  sms_count     :integer          default(50)
#  user_id       :integer          default(274)
#  expiration    :datetime         default(Tue, 13 Jun 2017 19:24:21 UTC +00:00)
#  promo_code_id :integer
#

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'roles' do
    it 'is free role' do
      user = build(:user, expiration: nil)
      expect(user.role).to eq(:free)
      expect(user.free?).to be_truthy
      expect(user.pro?).to be_falsey
    end

    it 'is pro role' do
      user = build(:user, :pro, expiration: nil)
      expect(user.role).to eq(:pro)
      expect(user.pro?).to be_truthy
      expect(user.free?).to be_falsey
    end

    context 'with expiration' do
      it 'is pro role if not expired' do
        user = build(:user, :pro, expiration: 1.day.from_now)
        expect(user.role).to eq(:pro)
        expect(user.pro?).to be_truthy
      end

      it 'is free role if expired' do
        user = build(:user, :pro, expiration: 1.day.ago)
        expect(user.role).to eq(:free)
        expect(user.pro?).to be_falsey
      end
    end
  end
end

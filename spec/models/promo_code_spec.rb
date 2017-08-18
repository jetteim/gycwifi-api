# == Schema Information
#
# Table name: promo_codes
#
#  id         :integer          not null, primary key
#  code       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  agent_id   :integer
#

require 'rails_helper'

RSpec.describe PromoCode, type: :model do
  context '#generate_for_agent' do
    let(:agent) { create(:agent) }

    before { @promo_code = described_class.generate_for_agent(agent) }
    it 'generates code for agent' do
      expect(agent.promo_codes[0]).to eq(@promo_code)
    end
  end
end

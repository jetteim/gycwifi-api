# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  username   :string           not null
#  email      :string           not null
#  password   :string           not null
#  avatar     :string           default("/images/avatars/default.jpg")
#  type       :string           default("FreeUser"), not null
#  tour       :boolean          default(TRUE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  lang       :string           default("ru")
#  sms_count  :integer
#  user_id    :integer          default(274)
#  expiration :datetime         default(Mon, 05 Jun 2017 06:29:47 UTC +00:00)
#

class AgentUser < User #:nodoc:
  has_many :agent_infos, foreign_key: 'referral_id', dependent: :destroy

  def reward_collected
    0
  end

  def reward_paid_out
    0
  end

  def reward_balance
    reward_collected - reward_paid_out
  end
end

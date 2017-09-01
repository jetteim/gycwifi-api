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

class ExclusiveUser < User #:nodoc:
  def front_permissions
    super.merge('dashboard.opinions' => false)
  end
end

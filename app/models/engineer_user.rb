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
#  sms_count     :integer
#  user_id       :integer          default(274)
#  expiration    :datetime         default(Mon, 05 Jun 2017 06:29:47 UTC +00:00)
#  promo_code_id :integer
#

class EngineerUser < User #:nodoc:
end

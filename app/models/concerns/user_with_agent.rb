# Общие вещи для пользователей, которые зарегистрировались через агента
module UserWithAgent
  extend ActiveSupport::Concern

  included do
    has_one :agent_info, foreign_key: 'user_id', dependent: :destroy

    # delegate :user, to: :agent_info
  end
end

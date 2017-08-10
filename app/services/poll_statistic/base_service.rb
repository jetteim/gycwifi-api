module PollStatistic
  class BaseService
    def initialize(poll)
      @poll = poll
      post_initialize
    end

    def post_initialize; end
  end
end

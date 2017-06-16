class TelegramedException
  def initialize(exception)
    TelegramWorker.new.perform(exception)
  end
end

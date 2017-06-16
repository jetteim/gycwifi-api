class SmsSender < ApplicationJob
  queue_as :sms

  def perform(code, phone)
    config = YAML.load_file(File.join(Rails.root, 'config', 'sms_service.yml'))
    logger.info "отправляем смс с кодом #{code} на номер #{phone}".magenta
    RestClient.post(config['url'] + '/SendMessage', mcommunicator(config, phone, code))
  end

  def mcommunicator(config, phone, code)
    {
      msid: long_phone_number(phone.to_s),
      message: code,
      naming: config['naming'],
      login: config['login'],
      validityPeriod: '70',
      password: Digest::MD5.hexdigest(config['password'])
    }
  end

  def long_phone_number(phone_number)
    result = phone_number.gsub(/[^\d,\.]/, '')
    case result.length
    when 10
      result = "7#{result}"
    when 11
      result[0] = '7' if result[0] == '8'
    end
    result
  end
end

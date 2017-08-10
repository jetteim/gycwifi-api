class MikroTik
  @@vars = [
    'mac',
    'platform_os',
    'platform_product',
    'ip',
    'username',
    'chap-id',
    'chap-challenge',
    'mac-esc',
    'link-login',
    'link-login-only',
    'link-orig',
    'link-orig-esc',
    'trial',
    'error',
    'nas_cn',
    'nas_serial'
  ]

  def self.fromCACHE(params)
    ret = {}
    @@vars.each do |name|
      ret[name.to_sym] = params[name] || params[name.to_sym]
    end
    ret
  end

  def self.asHTMLForm
    html = ''
    @@vars.each do |k|
      html += '<input type="hidden" name="' + k + '" value="$(' + k + ')" />' + "\n"
    end
    html
  end

  def self.unquote(str)
    str.gsub(/\\(\d{3})/) do |oct|
      oct = oct[1..-1]
      oct.chomp.to_i(8).chr
    end
  end

  def self.chapPassword(indata, clear_password)
    data = fromCACHE(indata)
    Digest::MD5.hexdigest(
      unquote(data['chap-id']) +
      clear_password +
      unquote(data['chap-challenge'])
    )
  end
end

if $PROGRAM_NAME == __FILE__
  m = MikroTik.unquote('\032\226')
  puts 'Unquoted: ' + m
  # print MikroTik.asHTMLForm()
end

require 'openssl'

# http://ruby-doc.org/stdlib-2.2.1/libdoc/openssl/rdoc/OpenSSL.html

class SSLGenerator
  def initialize
    @years = 10
    @dn = Hash[
      'C'  => 'US', # 2-letter country code
      'ST' => 'MyState',
      'L'  => 'MyCity',
      'O'  => 'MyOrganization',
      'OU' => 'MyOrganizationalUnit',
      'DC' => 'example.org',
      'CN' => 'client',
      'emailAddress' => 'client@example.org',
    ]
  end

  def load_ca(ca_cert_filename = 'ca.crt', ca_key_filename = 'ca.key', ca_basedir = '.')
    @ca_cert = OpenSSL::X509::Certificate.new File.read File.join(ca_basedir, ca_cert_filename)
    @ca_key = OpenSSL::PKey::RSA.new File.read File.join(ca_basedir, ca_key_filename)

    # print ca_key.public? # => true
    # print ca_cert

    # open 'private_key.pem', 'w' do |io| io.write key.to_pem end
    # open 'public_key.pem', 'w' do |io| io.write key.public_key.to_pem end
    self
  end

  def set_dn(name, value = nil)
    return set_dn(name => value) unless value.nil?
    name.each do |key, val|
      raise "Unknown DN attribute '" + key.to_s + "'" unless @dn.key?(key)
      @dn[key] = val
    end
    self
  end

  def set_name(value)
    set_dn('CN', value)
  end

  def generate
    key = OpenSSL::PKey::RSA.new 2048

    name = OpenSSL::X509::Name.new

    @dn.each do |k, v|
      name.add_entry k, v
    end

    csr = OpenSSL::X509::Request.new
    csr.version = 0
    csr.subject = name
    csr.public_key = key.public_key
    csr.sign key, OpenSSL::Digest::SHA1.new

    cert = OpenSSL::X509::Certificate.new
    cert.serial = 0
    cert.version = 2
    cert.not_before = Time.now
    cert.not_after = Time.now + 60 * 60 * 24 * 365 * @years

    cert.subject = csr.subject
    cert.public_key = csr.public_key
    cert.issuer = @ca_cert.subject

    extension_factory = OpenSSL::X509::ExtensionFactory.new
    extension_factory.subject_certificate = cert
    extension_factory.issuer_certificate = @ca_cert

    cert.add_extension extension_factory.create_extension('basicConstraints', 'CA:FALSE')
    cert.add_extension extension_factory.create_extension('keyUsage', 'keyEncipherment,dataEncipherment,digitalSignature')
    cert.add_extension extension_factory.create_extension('subjectKeyIdentifier', 'hash')

    cert.sign @ca_key, OpenSSL::Digest::SHA1.new

    @cert = cert
    @k = key

    self
  end

  def write_files(cert_dir, cert_base)
    File.open(File.join(cert_dir, cert_base + '.pem'), 'w') { |io| io.write @k.to_pem }
    File.open(File.join(cert_dir, cert_base + '.crt'), 'w') { |io| io.write @cert.to_pem }
  end

  def tupple
    Hash[
      'crt' => @cert.to_pem,
      'key' => @k.to_pem,
      # 'pub' => @k.public_key.to_pem
    ]
  end
end

if $PROGRAM_NAME == __FILE__

  gen = SSLGenerator.new
  gen.load_ca('ca.crt', 'ca.key', '.')
  gen.set_dn('O' => 'OrganizationName')
  gen.set_name('RUBY')
  gen.generate
  gen.write_files('.', 'rlient1')

  puts gen.tupple

end

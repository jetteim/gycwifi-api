class GeneratePromoCodeService
  class << self
    def call
      g_code = generate_code
      g_code = generate_code while PromoCode.exists?(code: g_code)
      g_code
    end

    private

    def generate_code
      (1..8).map { [*'A'..'Z', *'0'..'9'].sample }.join
    end
  end
end

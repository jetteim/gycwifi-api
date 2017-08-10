class ImageEncoder
  def self.encode_file(image_code)
    image = image_code.split(',')[1..-1].first.to_s
    decoded_image = Base64.decode64(image)
    decoded_image
  end
end

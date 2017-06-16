class UploadsController < ApplicationController
  before_action :file_code
  skip_before_action :authenticate_user

  # Определяем тип файла из параметров и инициализируем одноимённый метод
  def recieve_file
    case @str_prms[:entity]
    when 'brand'
      send(:brand)
    when 'brand_logo'
      send(:brand_logo)
    when 'brand_background'
      send(:brand_background)
    when 'location_logo'
      send(:location_logo)
    when 'location_background'
      send(:location_background)
    when 'user_avatar'
      send(:user_avatar)
    else
      render json: { error: 'Wrong file type or format' }
    end
  end

  # Логотип для бренда
  def brand_logo
    route = route_to_file('brand_logo')
    write_file(route, temp_file(@file_code))
    render json: { url: '/' + route.to_s.split('/')[-3..-1].join('/') }
  end

  # Задний фон для бренда
  def brand_background
    route = route_to_file('brand_background')
    write_file(route, temp_file(@file_code))
    render json: { url: '/' + route.to_s.split('/')[-3..-1].join('/') }
  end

  def location_logo
    route = route_to_file('location_logo')
    write_file(route, temp_file(@file_code))
    render json: { url: '/' + route.to_s.split('/')[-3..-1].join('/') }
  end

  def location_background
    route = route_to_file('location_background')
    write_file(route, temp_file(@file_code))
    render json: { url: '/' + route.to_s.split('/')[-3..-1].join('/') }
  end

  def user_avatar
    route = route_to_file('user_avatar')
    write_file(route, temp_file(@file_code))
    render json: { url: '/' + route.to_s.split('/')[-3..-1].join('/') }
  end

  private

  # Base64 код файла
  def file_code
    @file_code = @str_prms[:file_code]
  end

  # Создание файла изобаржения
  def write_file(route, temp_file)
    File.open(route, 'w:ASCII-8BIT') do |f|
      f.write(temp_file)
    end
  end

  # Временный файл
  def temp_file(file_code)
    ImageEncoder.encode_file(file_code)
  end

  # Адрес до файла
  def route_to_file(entity)
    file_name     = SecureRandom.uuid + '.png'
    route_to_file = Rails.root.join('public', 'images', entity) + file_name
    route_to_file
  end
end

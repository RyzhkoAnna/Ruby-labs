require 'uri'
require 'cgi'

module UrlNormalizer
  # Метод нормалізації URL
  def self.normalize(url)
    uri = URI.parse(url.to_s)
    
    return url unless uri.query
    
    # 1. Парсинг та фільтрація параметрів
    params = CGI.parse(uri.query)

    # Фільтрація
    filtered_params = params.reject { |key, _values| key.start_with?('utm_') }
    
    # 2. Сортування параметрів та збірка
    new_query = filtered_params.sort.map do |key, values|
      values.map do |value|
        "#{URI.encode_www_form_component(key)}=#{URI.encode_www_form_component(value)}"
      end
    end.flatten.join('&')

    # 3. Формування нового URL
    if new_query.empty?
      uri.query = nil
    else
      uri.query = new_query
    end

    # Повертаємо нормалізований URL як рядок
    uri.to_s
  rescue URI::InvalidURIError => e
    # Обробка недійсного URI
    puts "Помилка URI: #{e.message}"
    url # Повертаємо оригінальний рядок у разі помилки
  end
end
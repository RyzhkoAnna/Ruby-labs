require 'uri'
require 'cgi'

module UrlNormalizer
  # Метод нормалізації URL
  def self.normalize(url)
    uri = URI.parse(url.to_s)
    
    # Якщо немає рядка запиту, повертаємо URL як є.
    return url unless uri.query
    
    # 1. Парсинг та фільтрація параметрів
    # CGI.parse повертає хеш, де значення – це масиви (навіть якщо одне значення)
    params = CGI.parse(uri.query)

    # Фільтрація: видаляємо всі параметри, що починаються з 'utm_'
    filtered_params = params.reject { |key, _values| key.start_with?('utm_') }
    
    # 2. Сортування параметрів та збірка
    # Створюємо новий рядок запиту з відсортованих параметрів
    new_query = filtered_params.sort.map do |key, values|
      # CGI.parse завжди повертає масив, тому враховуємо це при збірці
      values.map do |value|
        # Використовуємо URI.encode_www_form_component для коректного кодування
        "#{URI.encode_www_form_component(key)}=#{URI.encode_www_form_component(value)}"
      end
    end.flatten.join('&')

    # 3. Формування нового URL
    if new_query.empty?
      # Якщо параметри були, але всі видалені, прибираємо '?'
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
# Для локального запуску:
require_relative 'lib/url_normalizer'

puts " Демонстрація роботи URL Normalizer "

urls = [
  "https://shop.com/product?z=100&a=50&utm_source=google&c=75",
  "http://example.org/path?utm_content=banner&id=123",
  "https://simple-site.net/page?x=1&y=2",
  "https://pure.com/no-params"
]

urls.each_with_index do |original_url, index|
  puts "\n[#{index + 1}] Оригінальний URL:"
  puts "    #{original_url}"
  
  # Виклик методу нормалізації з гему
  normalized_url = UrlNormalizer.normalize(original_url)
  
  puts "    => Нормалізований URL:"
  puts "    #{normalized_url}"
end
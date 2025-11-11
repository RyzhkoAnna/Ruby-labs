# Запускаємо гем, який тестуємо
require 'url_normalizer' 

RSpec.describe UrlNormalizer do
  # Тест 1: Сортування параметрів
  it 'сортує параметри запиту в алфавітному порядку' do
    original_url = 'https://example.com/page?z=1&a=3&b=2'
    expected_url = 'https://example.com/page?a=3&b=2&z=1'
    expect(UrlNormalizer.normalize(original_url)).to eq(expected_url)
  end

  # Тест 2: Видалення utm/* параметрів
  it 'видаляє всі параметри, що починаються з utm_' do
    original_url = 'https://example.com/page?param1=test&utm_source=google&param2=value'
    expected_url = 'https://example.com/page?param1=test&param2=value'
    expect(UrlNormalizer.normalize(original_url)).to eq(expected_url)
  end
  
  # Тест 3: Комбінований сценарій (сортування та видалення utm)
  it 'виконує сортування та видалення utm одночасно' do
    original_url = 'http://site.com/test?c=3&utm_medium=email&a=1&b=2&utm_campaign=winter'
    expected_url = 'http://site.com/test?a=1&b=2&c=3'
    expect(UrlNormalizer.normalize(original_url)).to eq(expected_url)
  end
  
  # Тест 4: Обробка URL без параметрів
  it 'повертає оригінальний URL, якщо параметри відсутні' do
    original_url = 'https://example.com/page'
    expect(UrlNormalizer.normalize(original_url)).to eq(original_url)
  end
  
  # Тест 5: Видалення лише utm-параметрів
  it 'прибирає ? якщо після видалення utm не залишилося параметрів' do
    original_url = 'https://example.com/page?utm_source=fb&utm_content=promo'
    expected_url = 'https://example.com/page'
    expect(UrlNormalizer.normalize(original_url)).to eq(expected_url)
  end
end
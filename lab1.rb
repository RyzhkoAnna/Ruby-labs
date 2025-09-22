def word_stats(text)
  # Обираємо тільки слова
  words = text.scan(/\p{L}+/)

  {
    total_words: words.size, # К-сть слів без пунктуації
    longest_word: words.max_by { |word| word.length } || '', # Страховка від порожніx значень
    count_unique: words.map { |word| word.downcase }.uniq.size # Вибірка унікальних слів
  }
end

print 'Введіть своє речення: '
text = gets.chomp

stats = word_stats(text)
puts "#{stats[:total_words]} слів, найдовше: #{stats[:longest_word]}, унікальних: #{stats[:count_unique]}."

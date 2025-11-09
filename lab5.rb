# 1. Створення початкової лямбди
sum3 = ->(a, b, c) { a + b + c }

# 2. Визначення функції каррірування (Currying)
def curry3(proc_or_lambda)
  # Перевіряємо, чи вхідний об'єкт дійсно є callable (Proc або Lambda)
  unless proc_or_lambda.is_a?(Proc)
    raise ArgumentError, "curry3 очікує Proc або Lambda як аргумент."
  end
  
  # Очікувана кількість аргументів
  required_args = 3
  
  # Внутрішня рекурсивна лямбда, яка керує станом
  curry_builder = ->(*args) do
    # Об'єднуємо всі зібрані аргументи
    collected_args = args.flatten
    
    # Захист від забагато аргументів (включаючи ті, що вже були зібрані)
    if collected_args.size > required_args
      raise ArgumentError, "Забагато аргументів. Очікується #{required_args}, отримано #{collected_args.size}."
    end
    
    # Якщо зібрано достатньо аргументів
    if collected_args.size == required_args
      # Викликаємо оригінальну лямбду (зберігаємо її контекст за допомогою proc_or_lambda.call)
      return proc_or_lambda.call(*collected_args)
    end
    
    # Якщо аргументів недостатньо, повертаємо нову лямбду, яка чекає наступну порцію аргументів.
    # Нова лямбда запам'ятовує (закриває) поточні зібрані аргументи (collected_args) та об'єднує їх з новими (*new_args).
    ->(*new_args) do
      # Рекурсивно викликаємо curry_builder, передаючи об'єднаний масив аргументів
      curry_builder.call(collected_args + new_args)
    end
  end
  
  # Повертаємо початковий callable-об'єкт, який починає процес
  curry_builder
end

# ТЕСТУВАННЯ

puts "ТЕСТУВАННЯ ФУНКЦІЇ CURRY3"
cur = curry3(sum3)

# 1. Тест виклику по одному аргументу
result1 = cur.call(1).call(2).call(3)
puts "cur.call(1).call(2).call(3)    => #{result1}"

# 2. Тест виклику згрупованими аргументами
result2 = cur.call(1, 2).call(3)
puts "cur.call(1, 2).call(3)         => #{result2}"

# 3. Тест виклику іншим групуванням
result3 = cur.call(1).call(2, 3)
puts "cur.call(1).call(2, 3)         => #{result3}"

# 4. Тест виклику всіх аргументів одразу
result4 = cur.call(1, 2, 3)
puts "cur.call(1, 2, 3)              => #{result4}"

# 5. Тест повернення callable-об'єкта (неповний виклик)
cur_partial = cur.call(1)
puts "cur.call(1) повертає об'єкт класу: #{cur_partial.class}"

# 6. Тест на ArgumentError (забагато аргументів)
begin
  cur.call(1, 2, 3, 4)
rescue ArgumentError => e
  puts "cur.call(1, 2, 3, 4)         => ArgumentError: #{e.message.split(':').last.strip}"
end

puts "\nДодатковий тест з рядками"
f = ->(a, b, c) { "#{a}-#{b}-#{c}" }
curried_f = curry3(f)
result7 = curried_f.call('A').call('B', 'C')
puts "curried_f.call('A').call('B', 'C')    => #{result7}"
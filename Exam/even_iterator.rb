# Модуль додає метод even_each до масивів
module EvenIterator
  def even_each
    unless block_given?
      return enum_for(:even_each) 
    end

    self.each do |element|
      if element.is_a?(Integer) && element.even?
        yield element 
      end
    end
    
    self
  end
end

# Додаю модуль до Array
class Array
  include EvenIterator
end

# Тестовий масив
numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, -10, "a", 12.5]
puts "Початковий масив: #{numbers.inspect}"

puts "\nДемонстрація роботи з блоком"
print "Виведення парних чисел: "
numbers.even_each do |num|
  print "#{num} "
end
puts

puts "\nДемонстрація роботи без блоку (як Enumerator)"
even_enum = numbers.even_each
multiplied_evens = even_enum.map { |num| num * 10 }

puts "Тип об'єкта: #{even_enum.class}"
puts "Результат map: #{multiplied_evens.inspect}"

doubled_evens = numbers.even_each.map { |n| n * 2 }
puts "Результат ланцюгового виклику: #{doubled_evens.inspect}"
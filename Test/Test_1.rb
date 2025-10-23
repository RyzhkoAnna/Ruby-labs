class FileBatchEnumerator
  attr_reader :file_path, :batch_size

  def initialize(file_path, batch_size)
    @file_path = file_path
    @batch_size = batch_size.to_i

    # Перевірки коректності
    raise ArgumentError, "batch_size має бути більше 0" if @batch_size <= 0
    raise ArgumentError, "Файл '#{@file_path}' не існує" unless File.exist?(@file_path)
    raise ArgumentError, "Файл '#{@file_path}' порожній" if File.zero?(@file_path)
  end

  def each_batch
    return enum_for(:each_batch) unless block_given?

    current_batch = []

    File.foreach(@file_path) do |line|
      current_batch << line.chomp
      if current_batch.size >= @batch_size
        yield current_batch
        current_batch = []
      end
    end

    yield current_batch unless current_batch.empty?
  end
end

# Демонстрація роботи програми

file_name = "big_file.txt"
line_count = 10_000

begin
  # Cтворюємо великий файл
  File.open(file_name, "w") do |file|
    line_count.times do |i|
      file.puts "Рядок номер #{i + 1}"
    end
  end

  puts "Файл '#{file_name}' створено з #{line_count} рядків."
  puts "\n"

  # Cтворюємо ітератор і читаємо батчами
  batch_size = 2000
  reader = FileBatchEnumerator.new(file_name, batch_size)

  batch_index = 0
  reader.each_batch do |batch|
    batch_index += 1
    puts "* Батч №#{batch_index} (рядків: #{batch.size})"
    puts "    Перший рядок: #{batch.first}"
  end

rescue ArgumentError => e
  puts "Помилка: #{e.message}"
rescue => e
  puts "Сталася непередбачена помилка: #{e.message}"
ensure
  # Видалення файлу
  if File.exist?(file_name)
    File.delete(file_name)
    puts "\nФайл '#{file_name}' успішно видалено."
  end
end

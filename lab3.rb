# frozen_string_literal: true

require "find"
require "json"
require "digest"

# Налаштування
ROOT = ARGV[0] || "."            # корінь сканування (позиційний аргумент або ".")
OUT  = "duplicates.json"         # записуємо в JSON

# Обчислює SHA-256 хеш файлу
def stream_sha256(path, buf_size: 4194304)  # Читаємо частинами по 4 МБ
  digest = Digest::SHA256.new
  File.open(path, "rb") do |f|
    while (chunk = f.read(buf_size))
      digest.update(chunk)
    end
  end
  digest.hexdigest
end

# 1) Рекурсивно зібрати {path, size, inode}
files = []
scanned = 0

Find.find(ROOT) do |path|
  begin
    next unless File.file?(path)               # лише звичайні файли
    st = File.lstat(path)
    if st.respond_to?(:ino)
      inode_value = st.ino
    else
      inode_value = nil
    end
    files << { path: path, size: st.size, inode: inode_value }
    scanned += 1
  rescue SystemCallError, IOError
    next # пропускаємо недоступні/биті файли
  end
end

# 2) Групи-кандидати за розміром
by_size = files.group_by { |h| h[:size] }
candidates = by_size.values.select { |arr| arr.size > 1 && arr.first[:size] > 0 }

# 3) Підтвердження: групування за повним SHA-256
dup_groups = []

candidates.each do |group|
  by_hash = {}  # порожній хеш

  group.each do |entry|
    begin
      sha = stream_sha256(entry[:path])

      # Якщо ключ уже є — додаємо файл у масив
      # Якщо ще немає — створюємо новий масив
      if by_hash.key?(sha)
        by_hash[sha] << entry
      else
        by_hash[sha] = [entry]
      end

    rescue SystemCallError, IOError
      # пропускаємо, якщо файл не читається
    end
  end

  # Додаємо тільки ті групи, де більше ніж один файл
  by_hash.values.each do |arr|
    dup_groups << arr if arr.size > 1
  end
end

# 4) Звіт
report_groups = dup_groups.map do |arr|
  size = arr.first[:size]
  {
    size_bytes: size,
    saved_if_dedup_bytes: size * (arr.size - 1),
    files: arr.map { |e| e[:path] }
  }
end

sorted_groups = report_groups.sort_by do |g|
  [-g[:saved_if_dedup_bytes], -g[:size_bytes]]
end

report = {
  scanned_files: scanned,
  groups: sorted_groups
}

# 5) Запис у JSON
File.write(OUT, JSON.pretty_generate(report))

puts "Scanned files: #{report[:scanned_files]}"
puts "Duplicate groups: #{report[:groups].size}"
puts "Report saved to: #{OUT}"

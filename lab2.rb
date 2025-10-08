# frozen_string_literal: true

# перевіряє і очищає вхідні дані торта
def normalize_cake(lines)
  cleaned = []                            

  lines.each do |row|                     # перебираємо кожен рядок з масиву lines
    no_spaces = row.gsub(/\s+/, "")       # видаляємо всі пробіли з рядка
    latin_o   = no_spaces.tr("о", "o")    # замінюємо кириличну "о" на латинську "o"
    cleaned << latin_o                    # додаємо результат у новий масив cleaned
  end

  # перевіряємо, щоб кожен рядок містив тільки '.' та 'o'
  cleaned.each do |row|
    if row.match?(/[^\.o]/)
      raise "рядки мають містити тільки '.' або 'o'"
    end
  end

  raise "порожній торт." if cleaned.empty?
  w = cleaned.first.size
  raise "нерівні рядки." unless cleaned.all? { |r| r.size == w }
  cleaned
end

# знаходить координати всіх родзинок 'o' у торті
def raisins_positions(grid)
  pos = []
  grid.each_with_index do |row, i|
    row.chars.each_with_index { |ch, j| pos << [i, j] if ch == 'o' }
  end
  pos
end

# Робить поворот торта
def transpose(grid)
  new_grid = []

  # проходимо по кожному стовпцю
  for j in 0...grid.first.size
    column = ""                    # новий рядок
    for i in 0...grid.size
      column += grid[i][j]         # додаємо символ із поточного рядка
    end
    new_grid << column             # додаємо зібраний стовпець у новий масив
  end

  return new_grid
end

# перевіряє, чи можна розрізати торт горизонтальними смугами
def try_horizontal_slices(grid)
  h_total = grid.size                 # кількість рядків
  w_total = grid.first.size           # кількість колонок (ширина)
  k = raisins_positions(grid).size    # кількість родзинок

  return nil if k <= 1                # потрібно принаймні 2 родзинки

  s = h_total * w_total               # площа торта
  return nil unless s % k == 0        # площа має ділитись на k

  a = s / k                           # площа одного шматка
  return nil unless a % w_total == 0  # смуга має бути на всю ширину

  band_h = a / w_total                # висота однієї горизонтальної смуги
  return nil unless band_h > 0
  return nil unless h_total % band_h == 0  # смуги мають рівно вкластися у висоту

  pieces = []
  # беремо смуги по band_h рядків
  (0...h_total).step(band_h) do |top|
    band = grid[top, band_h]    # беремо підряд band_h рядків
    # рахуємо, скільки 'o' у смузі
    cnt = band.sum { |row| row.count('o') }
    return nil unless cnt == 1  # у кожній смузі має бути рівно 1 родзинка
    pieces << band              # додаємо смугу до результату
  end

  pieces                         # повертаємо розріз
end

# перевіряє, чи можна розрізати торт вертикальними смугами
def try_vertical_slices(grid)
  h_total = grid.size           # висота торта (кількість рядків)
  w_total = grid.first.size     # ширина торта (кількість колонок)
  k = raisins_positions(grid).size

  return nil if k <= 1          # треба принаймні 2 родзинки

  s = h_total * w_total         # загальна площа
  return nil unless s % k == 0  # площа має ділитись на кількість шматків

  a = s / k                     # площа одного шматка

  # для вертикальних смуг: висота = h_total, отже ширина смуги:
  return nil unless a % h_total == 0
  band_w = a / h_total          # ширина однієї вертикальної смуги

  return nil unless band_w > 0
  return nil unless w_total % band_w == 0  # смуги мають рівно вкластися у ширину

  pieces = []                   # тут збиратимемо всі смуги-шматочки

  # рухаємось зліва направо кроком ширини смуги
  (0...w_total).step(band_w) do |left|
    # індекси колонок, які входять у поточну смугу
    cols = (left...(left + band_w)).to_a

    # будуємо смугу як масив рядків, вирізаючи лише ці колонки в кожному ряду
    band = []
    h_total.times do |i|
      row_part = ""
      cols.each do |j|
        row_part += grid[i][j]
      end
      band << row_part
    end

    # рахуємо, скільки родзинок у смузі
    cnt = 0
    band.each { |row| cnt += row.count('o') }

    # у смузі має бути рівно 1 родзинка
    return nil unless cnt == 1

    # якщо все ок — додаємо смугу в результат
    pieces << band
  end

  pieces
end

# знаходить усі можливі комбінації висоти і ширини (h×w)
def factor_pairs(area, max_h, max_w)
  pairs = []
  (1..max_h).each do |hh|
    next unless area % hh == 0
    ww = area / hh
    next if ww < 1 || ww > max_w
    pairs << [hh, ww]
  end
  pairs
end

# знаходить усі можливі позиції верхнього-лівого кута прямокутника
def rectangle_positions_including(h_piece, w_piece, r, c, h_total, w_total)
  tops  = [r - (h_piece - 1), 0].max .. [r, h_total - h_piece].min
  lefts = [c - (w_piece - 1), 0].max .. [c, w_total - w_piece].min
  tops.flat_map { |top| lefts.map { |left| [top, left] } }
end

# перевіряє, чи в обраному підпрямокутнику рівно 1 родзинка
def subgrid_has_exactly_one_raisin?(grid, top, left, h_piece, w_piece, taken)
  cnt = 0
  h_piece.times do |di|
    w_piece.times do |dj|
      i, j = top + di, left + dj
      return false if taken[i][j]
      cnt += 1 if grid[i][j] == 'o'
      return false if cnt > 1
    end
  end
  cnt == 1
end

# позначає клітинки як зайняті або звільнені
def paint_taken!(taken, top, left, h_piece, w_piece, val)
  h_piece.times do |di|
    w_piece.times do |dj|
      taken[top + di][left + dj] = val
    end
  end
end

# cортуємо кандидатів шматків
def sort_candidates!(candidates, first_piece)
  if first_piece
    # для першого шматка максимізуємо ширину (ww) — сортуємо за спаданням ширини
    candidates.sort! { |a, b| b[3] <=> a[3] }  # a=[top,left,hh,ww]
  else
    # для інших — стабільний порядок зверху-вниз, зліва-направо, потім за розміром
    candidates.sort! do |a, b|
      # порівнюємо послідовно: top, left, hh, ww
      a[0] == b[0] ? (a[1] == b[1] ? (a[2] == b[2] ? a[3] <=> b[3] : a[2] <=> b[2]) : a[1] <=> b[1]) : a[0] <=> b[0]
    end
  end
end

# pекурсія
def place_recursive(idx, k, raisins_sorted, pairs, grid, taken, h_total, w_total, pieces, best_solution_box)
  # база: усі родзинки закриті
  if idx == k
    best_solution_box[0] = pieces.map(&:dup)  # зберегли знайдене рішення
    return true
  end

  # координати поточної родзинки
  r, c = raisins_sorted[idx]

  # 1) збираємо кандидатів для поточної родзинки
  candidates = []  # елемент: [top, left, hh, ww]

  pairs.each do |pair|
    ph, pw = pair[0], pair[1]

    # пробуємо обидві орієнтації прямокутника: ph×pw і pw×ph
    orientations = [[ph, pw], [pw, ph]]

    orientations.each do |hh, ww|
      # усі позиції прямокутника hh×ww, які містять (r,c) і не виходять за межі
      positions = rectangle_positions_including(hh, ww, r, c, h_total, w_total)

      # відфільтруємо тільки ті, де рівно 1 родзинка і нічого не зайнято
      positions.each do |pos|
        top, left = pos[0], pos[1]
        if subgrid_has_exactly_one_raisin?(grid, top, left, hh, ww, taken)
          candidates << [top, left, hh, ww]
        end
      end
    end
  end

  # немає куди покласти шматок
  return false if candidates.empty?

  # 2) відсортуємо кандидатів
  sort_candidates!(candidates, idx == 0)

  # 3) перебираємо кандидатів по черзі
  candidates.each do |cand|
    top, left, hh, ww = cand

    # позначити зайняті клітинки
    paint_taken!(taken, top, left, hh, ww, true)

    # вирізати рядки шматка з оригінального торта
    piece_rows = []
    for i in top...(top + hh)
      piece_rows << grid[i][left, ww]
    end
    pieces << piece_rows

    # наступна родзинка
    if place_recursive(idx + 1, k, raisins_sorted, pairs, grid, taken, h_total, w_total, pieces, best_solution_box)
      return true
    end

    # відкат: забрати шматок і зняти позначку
    pieces.pop
    paint_taken!(taken, top, left, hh, ww, false)
  end

  # якщо всі варіанти перепробували — невдача на цьому рівні
  false
end

def backtrack_tiling(grid)
  # 0) базові обчислення
  h_total = grid.size
  w_total = grid.first.size
  raisins = raisins_positions(grid)
  k = raisins.size

  raise "кількість родзинок має бути більше 1 та менше 10." unless (2..9).include?(k)

  s = h_total * w_total
  raise "площа не ділиться на к-сть родзинок." unless s % k == 0
  a = s / k

  pairs = factor_pairs(a, h_total, w_total)
  raise "немає фактор-пар для площі шматка #{a}" if pairs.empty?

  # 1) швидкі варіанти
  horizontal = try_horizontal_slices(grid)
  return horizontal if horizontal

  vertical = try_vertical_slices(grid)
  return vertical if vertical

  # 2) підготовка для бектрекінгу
  taken = Array.new(h_total) { Array.new(w_total, false) }
  raisins_sorted = raisins.sort

  # 3) запускаємо просту рекурсію
  best_solution_box = [nil]     # коробочка для повернення рішення з глибини рекурсії
  ok = place_recursive(0, k, raisins_sorted, pairs, grid, taken, h_total, w_total, [], best_solution_box)

  raise "рішення не знайдено." unless ok
  best_solution_box[0]
end

def cut_cake(lines)
  grid = normalize_cake(lines)
  backtrack_tiling(grid)
end

# ввід для користувача
if __FILE__ == $0
  begin
    puts "Введіть кількість рядків торта:"
    h = Integer(STDIN.gets&.strip || "")
    raise "рядків має бути > 0" unless h.positive?

    lines = []
    puts "Введіть #{h} рядків торта ('.' та 'o'):"
    h.times do |i|
      print "рядок #{i+1}: "
      line = STDIN.gets
      raise "несподіваний кінець вводу." if line.nil?
      lines << line.chomp
    end

    pieces = cut_cake(lines)

    puts "\nРезультат:"
    puts "["
    pieces.each_with_index do |piece, idx|
      puts "  #{idx == 0 ? '' : ','}"
      piece.each { |row| puts "    #{row}" }
    end
    puts "]"
  rescue => e
    warn "\nПомилка: #{e.message}"
  end
end

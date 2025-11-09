# unit_converter.rb

module UnitConverter
  # Базові одиниці для кожного типу (маса, об'єм, штуки)
  BASE_UNITS = {
    mass: :g,
    volume: :ml,
    pcs: :pcs
  }.freeze

  # Співвідношення конвертації (множник для переведення до базової одиниці)
  CONVERSIONS = {
    g: { g: 1, kg: 1000 },
    ml: { ml: 1, l: 1000 },
    pcs: { pcs: 1 }
  }.freeze

  # Визначення типу одиниці
  def self.unit_type(unit)
    if [:g, :kg].include?(unit)
      :mass
    elsif [:ml, :l].include?(unit)
      :volume
    elsif unit == :pcs
      :pcs
    else
      nil
    end
  end

  # Конвертує кількість `qty` з одиниці `from_unit` до одиниці `to_unit`.
  # Заборонено конвертувати між різними типами (маса/об'єм/штуки).
  def self.convert(qty, from_unit, to_unit)
    # Перевірка на конвертацію між різними типами
    from_type = unit_type(from_unit)
    to_type = unit_type(to_unit)

    unless from_type == to_type
      raise ArgumentError, "Неможливо конвертувати з #{from_type} на #{to_type} (одиниці: #{from_unit} ↔ #{to_unit})."
    end

    return qty if from_unit == to_unit

    # 1. Переведення з початкової одиниці до базової
    base_unit = BASE_UNITS[from_type]
    base_qty = qty * CONVERSIONS[base_unit][from_unit]

    # 2. Переведення з базової одиниці до кінцевої
    final_qty = base_qty / CONVERSIONS[base_unit][to_unit]

    final_qty.round(4)
  end

  # Конвертує кількість до базової одиниці для її типу
  def self.to_base_unit(qty, unit)
    type = unit_type(unit)
    base_unit = BASE_UNITS[type]
    convert(qty, unit, base_unit)
  end
end
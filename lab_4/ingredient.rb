# ingredient.rb
require_relative 'unit_converter'

class Ingredient
  attr_reader :name, :base_unit, :calories_per_base_unit, :unit_type

  # Дозволені одиниці
  ALLOWED_UNITS = [:g, :kg, :ml, :l, :pcs].freeze

  def initialize(name, base_unit, calories_per_base_unit)
    raise ArgumentError, "Недозволена базова одиниця: #{base_unit}" unless ALLOWED_UNITS.include?(base_unit)

    @name = name
    @base_unit = base_unit
    @unit_type = UnitConverter.unit_type(base_unit)
    @calories_per_base_unit = calories_per_base_unit
  end

  # Калорійність інгредієнта в заданій кількості та одиниці
  def calculate_calories(qty, unit)
    # Спочатку конвертуємо до базової одиниці
    base_qty = UnitConverter.to_base_unit(qty, unit)
    (base_qty * @calories_per_base_unit).round(2)
  end
end
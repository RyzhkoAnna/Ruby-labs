# pantry.rb
require_relative 'unit_converter'

class Pantry
  def initialize
    @inventory = {} # { ingredient_name => { qty: base_qty, unit: base_unit } }
  end

  # Додає або оновлює інгредієнт у коморі, конвертуючи до базової одиниці.
  def add(ingredient, qty, unit)
    base_unit = ingredient.base_unit
    base_qty = UnitConverter.to_base_unit(qty, unit)
    name = ingredient.name

    if @inventory.key?(name)
      @inventory[name][:qty] += base_qty
    else
      @inventory[name] = { qty: base_qty, unit: base_unit }
    end
    @inventory[name][:qty] = @inventory[name][:qty].round(4) # Округлення
  end

  # Повертає наявну кількість інгредієнта в його базовій одиниці.
  def available_for(ingredient_name)
    @inventory.dig(ingredient_name, :qty) || 0.0
  end

  # Повертає базову одиницю для інгредієнта, якщо він є в коморі.
  def base_unit_for(ingredient_name)
    @inventory.dig(ingredient_name, :unit)
  end
end
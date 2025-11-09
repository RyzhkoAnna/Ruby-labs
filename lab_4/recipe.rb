# recipe.rb
require_relative 'unit_converter'

class Recipe
  attr_reader :name, :steps, :items

  def initialize(name, steps, items)
    @name = name
    @steps = steps
    @items = items # [{ingredient: Ingredient, qty: 100, unit: :g}, ...]
  end

  # Повертає хеш { ingredient_name => { qty: base_qty, unit: base_unit, ingredient: Ingredient } }
  # з кількістю, конвертованою до базових одиниць.
  def need
    needs = {}
    @items.each do |item|
      ingredient_name = item[:ingredient].name
      base_qty = UnitConverter.to_base_unit(item[:qty], item[:unit])

      needs[ingredient_name] = {
        qty: base_qty,
        unit: item[:ingredient].base_unit,
        ingredient: item[:ingredient]
      }
    end
    needs
  end

  # Розраховує загальну калорійність рецепту
  def total_calories
    @items.sum do |item|
      item[:ingredient].calculate_calories(item[:qty], item[:unit])
    end.round(2)
  end
end
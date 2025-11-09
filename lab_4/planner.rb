# planner.rb
require_relative 'unit_converter'

class Planner
  # price_list: { ingredient_name => price_per_base_unit }
  def self.plan(recipes, pantry, price_list)
    total_needs = {}
    total_calories = 0.0
    total_cost = 0.0

    # 1. Агрегація загальних потреб та калорій
    recipes.each do |recipe|
      recipe.need.each do |name, item|
        # Якщо елемента немає, ініціалізуємо його нулями.
        total_needs[name] ||= { need: 0.0, have: 0.0, deficit: 0.0, unit: item[:unit], ingredient: item[:ingredient] }
        
        # Тепер безпечно додаємо кількість, оскільки need: вже існує.
        total_needs[name][:need] += item[:qty]
      end

      # Додаємо калорії
      total_calories += recipe.total_calories
    end

    # 2. Розрахунок наявної кількості, дефіциту та вартості
    total_needs.each do |name, data|
      have_qty = pantry.available_for(name)
      data[:have] = have_qty.round(4)

      deficit = [0.0, data[:need] - have_qty].max
      data[:deficit] = deficit.round(4)

      # Розрахунок вартості (тільки для дефіциту)
      price = price_list[name] || 0.0 # Ціна за базову одиницю
      total_cost += deficit * price
    end

    # 3. Формування результату для виводу
    result = {
      summary: {}, # { name => { need: ..., have: ..., deficit: ..., unit: ... } }
      total_calories: total_calories.round(2),
      total_cost: total_cost.round(2)
    }

    total_needs.each do |name, data|
      result[:summary][name] = {
        need: data[:need],
        have: data[:have],
        deficit: data[:deficit],
        unit: data[:unit]
      }
    end

    result
  end
end
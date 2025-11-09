# demo.rb
require_relative 'unit_converter'
require_relative 'ingredient'
require_relative 'recipe'
require_relative 'pantry'
require_relative 'planner'

#  1. Ініціалізація інгредієнтів

# Калорії/база: яйце 72/шт; молоко 0.06/мл; борошно 3.64/г; паста 3.5/г; соус 0.2/мл; сир 4.0/г
puts "Ініціалізація інгредієнтів та калорійності:"
i_egg = Ingredient.new("яйця", :pcs, 72.0)
i_milk = Ingredient.new("молоко", :ml, 0.06)
i_flour = Ingredient.new("борошно", :g, 3.64)
i_pasta = Ingredient.new("паста", :g, 3.5)
i_sauce = Ingredient.new("соус", :ml, 0.2)
i_cheese = Ingredient.new("сир", :g, 4.0)


puts "Борошно (база: #{i_flour.base_unit}, кал/од: #{i_flour.calories_per_base_unit})"
puts "Молоко (база: #{i_milk.base_unit}, кал/од: #{i_milk.calories_per_base_unit})"
puts "\n"
## 2. Ініціалізація Комори

# Комора: борошно 1 кг; молоко 0.5 л; яйця 6 шт; паста 300 г; сир 150 г
puts "Наповнення Комори:"
pantry = Pantry.new
pantry.add(i_flour, 1, :kg)
pantry.add(i_milk, 0.5, :l)
pantry.add(i_egg, 6, :pcs)
pantry.add(i_pasta, 300, :g)
pantry.add(i_cheese, 150, :g)

puts "Борошно в коморі: #{pantry.available_for("борошно").to_i} #{pantry.base_unit_for("борошно")} (1 кг → 1000 г)"
puts "Молоко в коморі: #{pantry.available_for("молоко").to_i} #{pantry.base_unit_for("молоко")} (0.5 л → 500 мл)"
puts "\n"

## 3. Ініціалізація Рецептів

# Рецепти: «Омлет» (яйця 3 шт, молоко 100 мл, борошно 20 г);
#          «Паста» (паста 200 г, соус 150 мл, сир 50 г)
puts "Визначення Рецептів:"

r_omelet = Recipe.new(
  "Омлет",
  ["Збити яйця", "Додати молоко та борошно", "Смажити"],
  [
    { ingredient: i_egg, qty: 3, unit: :pcs },
    { ingredient: i_milk, qty: 100, unit: :ml },
    { ingredient: i_flour, qty: 20, unit: :g }
  ]
)

r_pasta = Recipe.new(
  "Паста",
  ["Відварити пасту", "Підігріти соус", "Змішати, посипати сиром"],
  [
    { ingredient: i_pasta, qty: 200, unit: :g },
    { ingredient: i_sauce, qty: 150, unit: :ml },
    { ingredient: i_cheese, qty: 50, unit: :g }
  ]
)

recipes = [r_omelet, r_pasta]
puts "Омлет: #{r_omelet.total_calories} кал."
puts "Паста: #{r_pasta.total_calories} кал."
puts "\n"
## 4. Ініціалізація цін та Планування

# Ціни (за базу): борошно г=0.02; молоко мл=0.015; яйце шт=6.0; паста г=0.03; соус мл=0.025; сир г=0.08
puts "Виконання Планування:"
price_list = {
  "борошно" => 0.02,
  "молоко" => 0.015,
  "яйця" => 6.0,
  "паста" => 0.03,
  "соус" => 0.025,
  "сир" => 0.08
}

plan_result = Planner.plan(recipes, pantry, price_list)

## 5. Вивід результату

puts "\nPLANNER - RecipeCraft"
puts "Інгредієнт      | Потрібно |Наявність | Дефіцит | Од. "
puts "----------------|----------|----------|---------|-----"

# Сортуємо для кращого виводу
sorted_summary = plan_result[:summary].sort_by { |name, data| name }

sorted_summary.each do |name, data|
  puts "%-15s | %8.2f | %8.2f | %7.2f | %s" % [
    name, data[:need], data[:have], data[:deficit], data[:unit]
  ]
end

puts "----------------|----------|----------|---------|-----"
puts "*Загальна Калорійність Рецептів: #{plan_result[:total_calories]} кал"
puts "*Загальна Вартість Дефіциту: #{plan_result[:total_cost]} грн"

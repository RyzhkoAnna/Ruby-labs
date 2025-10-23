# Сервіс для надсилання повідомлень через будь-який об'єкт із методом #deliver
class Notifier
  def initialize(adapter)
    # Перевіряємо, чи адаптер має метод deliver
    unless adapter.respond_to?(:deliver)
      raise ArgumentError, "Адаптер повинен реалізовувати метод #deliver(message)"
    end

    @adapter = adapter
  end

  # Викликає метод deliver у переданого адаптера
  def notify(message)
    @adapter.deliver(message)
  end
end

# Мок адаптера для Email
class EmailAdapter
  def deliver(message)
    puts "* Email: #{message}"
  end
end

# Мок адаптера для Slack
class SlackAdapter
  def deliver(message)
    puts "* Slack: #{message}"
  end
end

# Приклад використання
email_notifier = Notifier.new(EmailAdapter.new)
slack_notifier = Notifier.new(SlackAdapter.new)

email_notifier.notify("Тестове повідомлення на Email!")
slack_notifier.notify("Тестове повідомлення у Slack!")

# Перевірка, що помилка спрацює, якщо передати неправильний об'єкт:
#not_a_valid_adapter = "Просто рядок"
#notifier = Notifier.new(not_a_valid_adapter) # => ArgumentError

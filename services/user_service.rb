require 'possibly'
require_relative '../models/user'

module UserService
  class << self
    def find_by_id(id)
      User.where(_id: id).first_or_create
    end

    def gold(id)
      find_by_id(id).gold
    end

    def withdraw(id, amount)
      user = find_by_id(id)
      if amount > user.gold
        None
      else
        user.gold -= amount
        user.save!
        Some(user)
      end
    end

    def deposit(id, amount)
      user = find_by_id(id)
      user.gold += amount
      user.save! ? Some(user) : None()
    end

    def check_in(id)
      user = find_by_id(id)

      if checked_in_today?(user)
        None()
      else
        reward = rand(5..100)
        deposit(id, reward)
        user.last_check_in_date = Date.today.to_s
        user.save!
        Some(reward)
      end
    end

    private

    def checked_in_today?(user)
      Maybe(user.last_check_in_date)
        .map { |date| date == Date.today.to_s }
        .or_else { false }
    end
  end
end

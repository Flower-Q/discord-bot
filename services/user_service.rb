require 'possibly'
require_relative 'transaction'
require_relative '../models/user'

module UserService
  class << self
    include Transaction

    def find_by_id(id)
      User.where(_id: id).first_or_create
    end

    def gold(id)
      find_by_id(id).gold
    end

    def withdraw(id, amount)
      user = find_by_id(id)
      if amount > user.gold
        None()
      else
        user.gold -= amount
        user.save!
        Some(gold: user.gold, delta: -amount)
      end
    end

    def deposit(id, amount)
      user = find_by_id(id)
      user.gold += amount
      user.save! ? Some(gold: user.gold, delta: amount) : None()
    end

    def transfer(sender_id, recipient_id, amount)
      transaction(User) { withdraw(sender_id, amount) }
        .pipe { deposit(recipient_id, amount) }
        .do_transaction
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
        Some(reward: reward)
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

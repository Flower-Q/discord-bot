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
      user.save! ? Some(user) : None
    end
  end
end

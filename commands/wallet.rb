require_relative 'command'
require_relative '../services/user_service'

class Wallet
  include Command

  def initialize(event)
    @event = event
  end

  def run
    gold = UserService.gold(user.id)
    respond_with_mention("余额：#{gold}元")
  end
end

require_relative 'command'
require_relative '../services/user_service'

class Bet
  include Command

  def initialize(event)
    @event = event
  end

  def run(arg)
    amount = arg.to_i
    return if amount.zero?

    thread = Thread.new { clean_up_messages }

    make_bet(amount)
    thread.join
  end

  private

  def make_bet(amount)
    gold = UserService.gold(user.id)
    return respond_insufficient_gold if gold < amount

    won = [true, false].sample

    update_gold(won, amount)
      .map(&method(:respond_bet_result))
      .or_else { respond_insufficient_gold }
  end

  def update_gold(won, amount)
    if won
      UserService.deposit(user.id, amount)
    else
      UserService.withdraw(user.id, amount)
    end
  end

  def respond_insufficient_gold
    respond_with_mention '余额不足！'
  end

  def respond_bet_result(gold:, delta:)
    respond_with_mention format("余额：#{gold}元 (%+d)", delta)
  end

  def clean_up_messages
    delete_last_bet_message
    message.delete
  end

  def delete_last_bet_message
    messages = channel.history(10)
    last_bet_message = find_bet_message(messages)
    last_bet_message.delete
  end

  def find_bet_message(messages)
    regex = Regexp.new "^#{user.mention} 余额：(\\d+)元 \\(.+\\)$"

    bet_message = messages.find do |message|
      bot_user.id == message.user.id && regex.match?(message.content)
    end

    Maybe(bet_message)
  end
end

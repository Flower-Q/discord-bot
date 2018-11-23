require_relative 'command'
require_relative '../services/user_service'

class Transfer
  include Command

  def initialize(event)
    @event = event
  end

  def run(mention, arg)
    mentions = message.mentions
    amount = arg.to_i

    return unless valid_args?(mentions, amount)

    recipient = mentions.first

    UserService.transfer(user.id, recipient.id, amount)
               .each { respond_success(mention) }
               .or_else { respond_failure }
  end

  def respond_success(recipient_mention)
    respond_with_mention "给 #{recipient_mention} 转账成功！"
  end

  def respond_failure
    respond_with_mention '转账失败！（余额不足。）'
  end

  private

  def valid_args?(mentions, amount)
    amount > 0 &&
      mentions.size == 1 &&
      ![user, bot_user].include?(mentions.first)
  end
end

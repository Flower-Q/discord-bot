require 'possibly'

require_relative 'command'

require_relative '../services/user_service'

class CheckIn
  include Command

  def initialize(event)
    @event = event
  end

  def run
    UserService.check_in(user.id)
               .map(&method(:respond_success))
               .or_else { respond_failure }
  end

  def respond_success(reward:)
    respond_with_mention("签到成功，奖励#{reward}元！")
  end

  def respond_failure
    respond_with_mention('您今天已经签到过了，明天再来哦~')
  end
end

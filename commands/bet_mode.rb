require_relative 'command'

require_relative 'bet'
require_relative '../helpers/command_helper'

class BetMode
  include Command

  def initialize(event)
    @event = event
  end

  BET_MODE_REGEX = /^\s*()(\d+|退出)\s*$/
  private_constant :BET_MODE_REGEX

  def run
    respond_with_mention '已开启赌徒模式，只需连续输入数字即可押注，输入“退出”关闭此模式。'
    user.await :bet_mode, contains: BET_MODE_REGEX do |bet_event|
      CommandHelper.execute(BetModeAction, BET_MODE_REGEX, bet_event)
    end
  end

  class BetModeAction
    include Command

    def initialize(event)
      @event = event
    end

    def run(arg)
      if arg == '退出'
        respond_with_mention '已关闭赌徒模式！'
        true
      else
        Bet.new(@event).run(arg)
        false
      end
    end
  end
end

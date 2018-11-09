require 'discordrb'

require_relative 'config/environment'
require_relative 'config/mongoid'
require_relative 'config/discord'

bot = Discordrb::Bot.new token: DISCORD_CONFIG['BOT_TOKEN']

require_relative 'commands/wallet'
require_relative 'commands/bet'
require_relative 'commands/bet_mode'
require_relative 'commands/check_in'

require_relative 'helpers/command_helper'

commands = [
  { regex: /^(钱包|錢包)$/, command: Wallet },
  { regex: /^(押注|押註)\s*(\d+)$/, command: Bet },
  { regex: /^(赌徒模式|賭徒模式)$/, command: BetMode },
  { regex: /^(签到|簽到)$/, command: CheckIn }
]

commands.each do |command|
  bot.message(contains: command[:regex]) do |event|
    CommandHelper.execute(command[:command], command[:regex], event)
  end
end

bot.run

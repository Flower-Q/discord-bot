require 'discordrb'

require_relative 'config/environment'
require_relative 'config/mongoid'
require_relative 'config/discord'

bot = Discordrb::Bot.new token: DISCORD_CONFIG['BOT_TOKEN']

require_relative 'commands/wallet'
require_relative 'commands/bet'
require_relative 'commands/bet_mode'
require_relative 'commands/check_in'
require_relative 'commands/transfer'
require_relative 'commands/slot/slot'

require_relative 'helpers/command_helper'

commands = [
  { regex: /^(钱包|錢包)$/, command: Wallet },
  { regex: /^(押注|押註)\s*(\d+)$/, command: Bet },
  { regex: /^(赌徒模式|賭徒模式)$/, command: BetMode },
  { regex: /^(签到|簽到)$/, command: CheckIn },
  { regex: /^(转账|轉帳)\s+(<@!?\d+>)\s+(\d+)$/, command: Transfer },
  { regex: /^(老虎机|老虎機|拉霸)$/, command: Slot }
]

commands.each do |regex:, command:|
  bot.message(contains: regex) do |event|
    CommandHelper.execute(command, regex, event)
  end
end

bot.run

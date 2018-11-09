require 'discordrb'

require_relative 'config/mongoid'
require_relative 'config/discord'

bot = Discordrb::Bot.new token: DISCORD_CONFIG['BOT_TOKEN']

require_relative 'commands/wallet'
require_relative 'commands/bet'

commands = [
  { regex: /^(钱包|錢包)$/, command: Wallet },
  { regex: /^(押注|押註)\s*(\d+)$/, command: Bet }
]

commands.each do |command|
  bot.message(contains: command[:regex]) do |event|
    matches = event.message.content.match(command[:regex]).captures
    _, *args = matches
    command_instance = command[:command].new(event)
    command_instance.run(*args)
  end
end

bot.run

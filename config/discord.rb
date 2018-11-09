require 'yaml'

DISCORD_CONFIG = YAML.load_file('config/discord.yml')
DISCORD_CONFIG['BOT_TOKEN'] = ENV['BOT_TOKEN'] if ENV['BOT_TOKEN']

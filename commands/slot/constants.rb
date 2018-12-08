class Slot
  UP_ARROW = "\u{1f53c}".freeze
  DOWN_ARROW = "\u{1f53d}".freeze
  STICK = "\u{1F579}".freeze
  CROSS = "\u{274c}".freeze
  private_constant :UP_ARROW, :DOWN_ARROW, :STICK, :CROSS

  REACTIONS = [UP_ARROW, DOWN_ARROW, STICK, CROSS].freeze
  private_constant :REACTIONS

  EMBED_TITLE = ':slot_machine::slot_machine: **老虎机** :slot_machine::slot_machine:'.freeze
  private_constant :EMBED_TITLE

  DEFAULT_AVATAR_URL = 'https://cdn.discordapp.com/embed/avatars/0.png'.freeze
  private_constant :DEFAULT_AVATAR_URL

  EMOJI_ACTION_TYPE_MAP = {
    UP_ARROW => :increase_bet,
    DOWN_ARROW => :decrease_bet,
    CROSS => :close
  }.freeze
  private_constant :EMOJI_ACTION_TYPE_MAP

  QUIT_EMBED = Discordrb::Webhooks::Embed.new(
    title: EMBED_TITLE,
    description: '**已退出游戏**'
  ).freeze
  private_constant :QUIT_EMBED

  TIMEOUT_EMBED = Discordrb::Webhooks::Embed.new(
    title: EMBED_TITLE,
    description: '**已自动退出（超时）**'
  ).freeze
  private_constant :TIMEOUT_EMBED
end

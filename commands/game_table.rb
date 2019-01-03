require_relative 'command'

class GameTable
  include Command

  # @return [Array<Discordrb::User>]
  attr_reader :players

  def initialize(event, game_name)
    @event = event
    @game_name = game_name
    @players = [user]
  end

  # @return [Array<Discordrb::User>, nil]
  def run
    @message = respond(message_content)
    create_reactions

    loop do
      event = await_reaction_event
      handle_reaction_event(event)
      break if @finish
    end

    @message.delete
    players.empty? ? nil : players
  end

  START = "\u{1F197}".freeze
  JOIN = "\u{2934}".freeze
  LEAVE = "\u{2935}".freeze
  private_constant :START, :JOIN, :LEAVE

  EMOJIS = [START, JOIN, LEAVE].freeze
  private_constant :EMOJIS

  def create_reactions
    EMOJIS.each { |emoji| @message.create_reaction(emoji) }
  end

  # @return [String]
  def message_content
    "#{@game_name} 游戏桌：\n" +
      players.map { |p| " - #{p.mention}#{' （桌长）' if p == owner}" }.join("\n")
  end

  # @return [Discordrb::Events::ReactionEvent]
  def await_reaction_event
    bot.add_await!(
      Discordrb::Events::ReactionAddEvent,
      message: @message, emoji: [START, JOIN, LEAVE]
    )
  end

  # @return [Discordrb::User]
  def owner
    players.first
  end

  def handle_reaction_event(event)
    case event.emoji.name
    when START
      start if event.user == owner
    when JOIN
      join(event.user)
    when LEAVE
      leave(event.user)
    else # rubocop:disable Style/EmptyElse
    end
  end

  def start
    return if players.size < 2

    @finish = true
  end

  def join(user)
    return if players.include?(user)

    players.push(user)
    update_message
  end

  def leave(user)
    return unless players.include?(user)

    players.delete(user)

    if players.empty?
      close
    else
      update_message
    end
  end

  def close
    @finish = true
  end

  def update_message
    @message.edit(message_content)
  end
end

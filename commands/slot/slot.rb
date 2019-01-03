require 'redux'

require_relative '../command'
require_relative '../../services/user_service'
require_relative '../../helpers/slot_game_helper'

require_relative 'constants'
require_relative 'redux'

class Slot
  include Command

  def initialize(event)
    @event = event
  end

  def run
    init_store
    init_embed
    init_embed_message
    init_store_listener

    handle_actions

    clear_reactions
  end

  private

  def init_store
    @store = Redux::Store.new(&Reducer::REDUCER)
    @store.dispatch(type: :set_gold,
                    payload: { gold: UserService.gold(user.id) })
  end

  def init_embed
    game = @store.state.game
    bet = @store.state.bet
    gold = @store.state.gold

    @embed = Discordrb::Webhooks::Embed.new(
      title: EMBED_TITLE,
      description: SlotGameHelper.map_to_embed_content(game),
      author: create_embed_author
    )

    @embed.add_field(name: '赌注', value: "$ #{bet}", inline: true)
    @embed.add_field(name: '余额', value: "$ #{gold}", inline: true)
  end

  def init_embed_message
    @embed_message = channel.send_embed('', @embed)
    create_reactions
  end

  def init_store_listener
    @store.subscribe do
      if @store.state.quit
        show_quit_embed(@store.state.timeout)
      else
        update_embed
      end
    end
  end

  def handle_actions
    loop do
      reaction = await_reaction
      handle_reaction(reaction)
      break if @store.state.quit
    end
  end

  def handle_reaction(reaction)
    case reaction
    when Some(STICK)
      start_bet
    when Some
      reaction.map { |emoji| EMOJI_ACTION_TYPE_MAP[emoji] }
              .each { |type| @store.dispatch(type: type) }
    else
      @store.dispatch(type: :timed_out)
    end
  end

  # @return [Maybe<String>]
  def await_reaction
    loop do
      event = bot.add_await!(
        Discordrb::Events::ReactionAddEvent,
        user: user, message: @embed_message, emoji: REACTIONS, timeout: 60
      )

      break Maybe(event).map { |e| e.emoji.name }
    end
  end

  def start_bet
    bet = @store.state.bet
    success = UserService.withdraw(user.id, bet)
    success.each do |gold:, delta:|
      @store.dispatch(type: :update_gold,
                      payload: { gold: gold, delta: delta })
    end

    @store.dispatch(type: :before_spin)
    animate
    reward
  end

  def animate
    [[5, 3], [2, 2], [2, 1]].each do |times, reels|
      times.times do
        @store.dispatch(type: :spin, payload: { reels: reels })
      end
    end
  end

  def reward
    game = @store.state.game

    multiples = [0, 3, 10]

    reward = @store.state.bet * multiples[game.identical_symbols - 1]
    return if reward.zero?

    success = UserService.deposit(user.id, reward)
    success.each do |gold:, delta:|
      @store.dispatch(type: :update_gold,
                      payload: { gold: gold, delta: delta })
    end
  end

  def update_embed_message
    thread = Thread.new { sleep 1 }
    @embed_message.edit('', @embed)
    thread.join
  end

  def update_embed
    slot_updated = @store.state.slot_updated
    values_updated = @store.state.values_updated

    return unless slot_updated || values_updated

    update_embed_content if slot_updated
    update_embed_fields if values_updated
    update_embed_message
  end

  def update_embed_content
    game = @store.state.game
    @embed.description = SlotGameHelper.map_to_embed_content(game)
  end

  def update_embed_fields
    state = @store.state

    bet = state.bet
    gold = state.gold
    delta = state.delta || 0

    @embed.fields[0].value = "$ #{bet}"
    @embed.fields[1].value = "$ #{gold}"
    @embed.fields[1].value += format(' (%+d)', delta) unless delta.zero?
  end

  # @return [Discordrb::Webhooks::EmbedAuthor]
  def create_embed_author
    embed_author_info = {
      name: user.name,
      icon_url: user.avatar_id.nil? ? DEFAULT_AVATAR_URL : user.avatar_url
    }

    Discordrb::Webhooks::EmbedAuthor.new(embed_author_info)
  end

  def show_quit_embed(timeout)
    @embed = timeout ? TIMEOUT_EMBED : QUIT_EMBED
    update_embed_message
  end

  def create_reactions
    REACTIONS.each { |emoji| @embed_message.create_reaction(emoji) }
  end

  def clear_reactions
    @embed_message.delete_all_reactions
  end
end

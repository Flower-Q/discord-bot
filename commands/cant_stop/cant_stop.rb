require 'redux'
require 'possibly'

require_relative '../command'
require_relative '../../commands/game_table'

require_relative 'actions'
require_relative 'reducers'
require_relative 'views'
require_relative 'characters'

class CantStop
  include Command

  def initialize(event)
    @event = event
  end

  def run
    table = GameTable.new(@event, '欲罢不能')
    @players = table.run

    if @players.nil?
      respond_closed_table
    else
      init_game
    end
  end

  private

  def init_game
    init_store
    init_message
    init_store_listener

    start_game
    show_scores
    clear_reactions
  end

  def init_store
    @store = Redux::Store.new({}, &Reducers::REDUCER)

    player_ids = @players.map(&:id)
    @store.dispatch(Actions.start_game(player_ids))
  end

  def init_message
    @message = respond '载入中……'
    REACTIONS.map { |r| @message.create_reaction(r) }
  end

  def init_store_listener
    @store.subscribe do
      update_message
    end
  end

  def start_game
    loop do
      @store.dispatch(Actions.start_turn(current_player.id))
      start_turn

      break unless @store.state[:winner_id].nil?

      alternate_turn
    end
  end

  def show_scores
    text = "游戏结束，<@#{@store.state[:winner_id]}> 赢了。\n\n"
    text += "分数：\n"
    text += @store.state[:players].map do |id, player|
      " - <@#{id}>：#{player[:score]}"
    end.join("\n")

    @message.edit(text)
  end

  def start_turn
    loop do
      if await_play_or_stop == :play
        continue = play_turn
        break unless continue
      else
        stop_turn
        break
      end
    end
  end

  # @return [true, false]
  def play_turn
    dices = roll_dices
    @store.dispatch(Actions.setup_dices(dices))

    continue = @store.state[:can_continue]

    if continue
      choice_num = await_move_choice
      @store.dispatch(Actions.choose_move(choice_num))
    else
      sleep(5)
    end

    continue
  end

  def stop_turn
    @store.dispatch(Actions.stop_turn)
  end

  # @return [:play, :stop]
  def await_play_or_stop
    case await_reactions(DICE, CROSS)
    when Some(DICE)
      :play
    else
      :stop
    end
  end

  # @return [Integer]
  def await_move_choice
    total_moves = @store.state[:possible_moves].flatten(1).size

    await_reactions(*NUMBERS[0...total_moves])
      .map { |num_emoji| NUMBERS.index(num_emoji) }
      .or_else(0)
  end

  # @return [Maybe<String>]
  def await_reactions(*reactions)
    loop do
      event = bot.add_await!(
        Discordrb::Events::ReactionAddEvent,
        user: current_player,
        message: @message,
        emoji: reactions,
        timeout: 300
      )

      break Maybe(event).map { |e| e.emoji.name }
    end
  end

  def update_message
    @message.edit(state_view)
  end

  def respond_closed_table
    respond '已关闭游戏桌。'
  end

  # @return [Discordrb::User]
  def current_player
    @players.first
  end

  def alternate_turn
    @players = @players.rotate
  end

  # @return [Array<Integer>]
  def roll_dices
    Array.new(4) { rand(1..6) }
  end

  def clear_reactions
    @message.delete_all_reactions
  end
end

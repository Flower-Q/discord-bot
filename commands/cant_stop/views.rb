require_relative 'characters'

class CantStop
  private

  # @return [String]
  def state_view
    subviews = %i[
      current_player_view
      board_view
      dices_view
      actions_view
      player_list_view
    ].map { |m| method(m).call(**@store.state) }

    combine_subviews(*subviews)
  end

  # @return [String]
  def combine_subviews(current_player, board, dices, actions, player_list)
    lines_hash = {
      space: "\u{3000}", board: board.lines, dice: dices.lines,
      action: actions.lines
    }

    args = Hash.new do |_, k|
      view, line_n = k.to_s.split('_')
      line = lines_hash[view.to_sym][line_n.to_i] || ''
      line.sub("\n", '')
    end

    "#{current_player}\n\n#{format(STATE_VIEW_FORMAT, args)}\n\n#{player_list}"
  end

  # @return [String]
  def current_player_view(current_player_id:, **_state)
    "<@#{current_player_id}> 的回合"
  end

  # @return [String]
  def board_view(**state)
    args = { backg: BACKGROUND }
    args.default_proc = proc do |_, k|
      if k.to_s.start_with?('col')
        column_tip_char(k.to_s.sub('col', '').to_i, state)
      else
        col, steps = k.to_s.split('_').map(&:to_i)
        marker_char_at(col, steps, state).or_else(NO_MARKERS)
      end
    end

    format(BOARD_VIEW_FORMAT, args)
  end

  # @return [String]
  def dices_view(dices: nil, waiting_move:, **_state)
    return '' unless waiting_move

    args = Hash.new do |_, k|
      index = k.to_s.sub('dice', '').to_i
      NUMBERS[dices[index] - 1]
    end

    format(DICES_VIEW_FORMAT, args)
  end

  # @return [String]
  def actions_view(waiting_move:, **state)
    return moves_view(**state) if waiting_move

    CONTINUE_OR_STOP_VIEW
  end

  def player_list_view(players:, **_state)
    lines = players.map do |id, player|
      "#{player_marker_char(players, id)} <@#{id}> 分数：#{player[:score]}"
    end

    lines.join("\n")
  end

  # @return [String]
  def moves_view(possible_moves: nil, dices: nil, **_state)
    return "\n" * 9 if dices.nil?

    move_views = single_move_views(possible_moves)
    args = Hash.new do |_, k|
      prefix, num = k.to_s.split('_')
      num = num.to_i
      prefix == 'dice' ? dices[num] : move_views[num]
    end

    format(MOVES_VIEW_FORMAT, args)
  end

  # @return [Array<String>]
  def single_move_views(possible_moves)
    nums = NUMBERS.dup

    move_views = possible_moves.map do |moves|
      moves.map do |m|
        fst, snd = m.map { |c| c + 2 }
        msg = fst == snd ? "#{fst}列进两步" : "#{fst}#{", #{snd}" if snd}列进一步"
        " - #{nums.shift} #{msg}"
      end
    end

    move_views.map { |fst, snd| [fst || '没有可选的组合。', snd || ''] }.flatten
  end

  MAX_STEPS = [3, 5, 7, 9, 11, 13, 11, 9, 7, 5, 3].freeze
  private_constant :MAX_STEPS

  def column_tip_char(col, **state)
    marker_char_at(col, MAX_STEPS[col], **state).or_else(NUMBERS[col + 1])
  end

  # @return [Maybe<String>]
  def marker_char_at(col, steps, neutral_markers:, completed_columns:, **state)
    if completed_columns.include?(col)
      Some(player_marker_char(state[:players], completed_columns[col]))
    elsif neutral_markers[col] == steps
      Some(NEUTRAL_MARKER)
    elsif state[:current_player_id]
      player_marker_char_at(col, steps, **state)
    else
      None()
    end
  end

  # @return [Maybe<String>]
  def player_marker_char_at(col, steps,
                            players:, current_player_id: nil, **_state)
    current_player = players[current_player_id]

    if current_player && current_player[:markers][col] == steps
      Some(player_marker_char(players, current_player_id))
    else
      player = players.find { |_, p| p[:markers][col] == steps }
      Maybe(player).map { |id, _| player_marker_char(players, id) }
    end
  end

  # @return [String]
  def player_marker_char(players, player_id)
    index = players.keys.sort.index(player_id)
    PLAYER_MARKERS[index]
  end

  def self.wrap_arg_name(name)
    "%<#{name}>s"
  end
  private_class_method :wrap_arg_name

  STATE_VIEW_FORMAT = [
    %w[board_00 space dice_00],
    %w[board_01 space dice_01],
    %w[board_02 space dice_02],
    %w[board_03],
    %w[board_04 space action_00],
    %w[board_05 space action_01],
    %w[board_06 space action_02],
    %w[board_07 space action_03],
    %w[board_08 space action_04],
    %w[board_09 space action_05],
    %w[board_10 space action_06],
    %w[board_11 space action_07],
    %w[board_12 space action_08]
  ].map { |line| line.map(&method(:wrap_arg_name)).join }.join("\n").freeze
  private_constant :STATE_VIEW_FORMAT

  BOARD_VIEW_FORMAT = [
    %w[backg backg backg backg backg col05 backg backg backg backg backg],
    %w[backg backg backg backg col04 05_12 col06 backg backg backg backg],
    %w[backg backg backg col03 04_10 05_11 06_10 col07 backg backg backg],
    %w[backg backg col02 03_08 04_09 05_10 06_09 07_08 col08 backg backg],
    %w[backg col01 02_06 03_07 04_08 05_09 06_08 07_07 08_06 col09 backg],
    %w[col00 01_04 02_05 03_06 04_07 05_08 06_07 07_06 08_05 09_04 col10],
    %w[00_02 01_03 02_04 03_05 04_06 05_07 06_06 07_05 08_04 09_03 10_02],
    %w[00_01 01_02 02_03 03_04 04_05 05_06 06_05 07_04 08_03 09_02 10_01],
    %w[backg 01_01 02_02 03_03 04_04 05_05 06_04 07_03 08_02 09_01 backg],
    %w[backg backg 02_01 03_02 04_03 05_04 06_03 07_02 08_01 backg backg],
    %w[backg backg backg 03_01 04_02 05_03 06_02 07_01 backg backg backg],
    %w[backg backg backg backg 04_01 05_02 06_01 backg backg backg backg],
    %w[backg backg backg backg backg 05_01 backg backg backg backg backg]
  ].map { |line| line.map(&method(:wrap_arg_name)).join }.join("\n").freeze
  private_constant :BOARD_VIEW_FORMAT

  DICES_VIEW_FORMAT = %W[
    骰子\u{1F3B2}
    \u{3000}%<dice0>s%<dice1>s
    \u{3000}%<dice2>s%<dice3>s
  ].join("\n").freeze
  private_constant :DICES_VIEW_FORMAT

  CONTINUE_OR_STOP_VIEW = "#{DICE} 继续\n#{CROSS} 停止".freeze

  MOVES_VIEW_FORMAT = [
    '组合 1：%<dice_0>s + %<dice_1>s 和 %<dice_2>s + %<dice_3>s',
    '%<move-view_0>s',
    '%<move-view_1>s',
    '组合 2：%<dice_0>s + %<dice_2>s 和 %<dice_1>s + %<dice_3>s',
    '%<move-view_2>s',
    '%<move-view_3>s',
    '组合 3：%<dice_0>s + %<dice_3>s 和 %<dice_1>s + %<dice_2>s',
    '%<move-view_4>s',
    '%<move-view_5>s'
  ].join("\n").freeze
  private_constant :MOVES_VIEW_FORMAT
end

class CantStop
  class Reducers
    class << self
      MAX_STEPS = [3, 5, 7, 9, 11, 13, 11, 9, 7, 5, 3].freeze
      private_constant :MAX_STEPS

      DEFAULT_VALUES = {
        completed_columns: {},
        neutral_markers: {},
        waiting_move: false
      }.freeze

      def start_game(state, player_ids:)
        players = player_ids.inject({}) do |hash, id|
          hash.merge(id => { markers: Array.new(11, 0), score: 0 })
        end

        state.merge(players: players).merge(DEFAULT_VALUES)
      end

      def start_turn(state, player_id:)
        state.merge(
          current_player_id: player_id,
          neutral_markers: {},
          dices: nil,
          waiting_move: false
        )
      end

      def setup_dices(state, dices:)
        markers, completed = state.values_at(:neutral_markers,
                                             :completed_columns)

        excluded_cols = excluded_columns(completed.keys, markers)
        combinations = dices_combinations(dices)

        moves = possible_moves(combinations, markers.keys, excluded_cols)

        state.merge(
          can_continue: can_continue?(moves),
          dices: dices, possible_moves: moves, waiting_move: true
        )
      end

      def choose_move(state, move_opt_index:)
        move_cols = state[:possible_moves].flatten(1)[move_opt_index]
        player_markers = state[:players][state[:current_player_id]][:markers]
        neutral_markers = state[:neutral_markers]

        state.merge(
          neutral_markers: update_neutral_markers(
            move_cols, player_markers, neutral_markers
          ),
          waiting_move: false
        )
      end

      def stop_turn(state)
        id, players, new_markers, old_completed = state.values_at(
          :current_player_id, :players, :neutral_markers, :completed_columns
        )

        completed = new_markers.select { |col, steps| steps == MAX_STEPS[col] }

        player = update_player(new_markers, players[id], completed)
        new_completed = update_completed_columns(old_completed, completed, id)
        winner_id = update_winner_id(id, player)

        state.merge(players: players.merge(id => player),
                    completed_columns: new_completed, winner_id: winner_id)
      end

      private

      def possible_moves(combinations, marked_cols, excluded_cols)
        remaining_markers = 3 - marked_cols.size

        case remaining_markers
        when 3, 2
          possible_moves_with_many(combinations, excluded_cols)
        when 1
          possible_moves_with_one(combinations, marked_cols, excluded_cols)
        else # when 0
          possible_moves_with_zero(combinations, marked_cols, excluded_cols)
        end
      end

      def update_neutral_markers(move_cols, player_markers, neutral_markers)
        move_cols.reduce(neutral_markers) do |markers, move_col|
          steps = markers[move_col] || player_markers[move_col]
          markers.merge(move_col => [steps + 1, MAX_STEPS[move_col]].min)
        end
      end

      def update_player(new_markers, player, completed)
        score = player[:score] + completed.size

        markers = player[:markers].map.with_index do |steps, i|
          [new_markers[i], steps].compact.max
        end

        { markers: markers, score: score }
      end

      def update_completed_columns(completed_cols, new_completed_cols, id)
        new_cols = new_completed_cols.keys.map { |col| [col, id] }.to_h
        completed_cols.merge(new_cols)
      end

      def update_winner_id(id, player)
        player[:score] >= 3 ? id : nil
      end

      def possible_moves_with_many(combinations, excluded_cols)
        combinations.map { |tuple| [tuple - excluded_cols].reject(&:empty?) }
      end

      def possible_moves_with_one(combinations, marked_cols, excluded_cols)
        combinations.map do |tuple|
          filtered_cols = tuple - excluded_cols
          fst, snd = filtered_cols

          if (filtered_cols & marked_cols).empty? && fst != snd
            filtered_cols.each_slice(1).to_a
          else
            [filtered_cols].reject(&:empty?)
          end
        end
      end

      def possible_moves_with_zero(all_moves, marked_cols, excluded_cols)
        all_moves.map do |tuple|
          [tuple - excluded_cols & marked_cols].reject(&:empty?)
        end
      end

      def excluded_columns(completed_cols, neutral_markers)
        [
          *completed_cols,
          *neutral_markers.select { |col, steps| MAX_STEPS[col] == steps }.keys
        ]
      end

      def dices_combinations(dices)
        fst, snd, trd, fth = dices.map { |n| n - 1 }

        [
          [fst + snd, trd + fth],
          [fst + trd, snd + fth],
          [fst + fth, snd + trd]
        ]
      end

      def can_continue?(possible_moves)
        possible_moves.any? { |move| !move.empty? }
      end
    end

    REDUCER = lambda do |state = {}, action|
      case action[:type]
      when :start_game
        start_game(state, action[:payload])
      when :start_turn
        start_turn(state, action[:payload])
      when :setup_dices
        setup_dices(state, action[:payload])
      when :choose_move
        choose_move(state, action[:payload])
      when :stop_turn
        stop_turn(state)
      else
        state
      end
    end
  end
end

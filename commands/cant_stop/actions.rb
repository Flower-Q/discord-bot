class CantStop
  class Actions
    class << self
      def self.define_action(type, params)
        define_method(type) do |*args|
          { type: type, payload: params.zip(args).to_h }
        end
      end

      [
        { type: :start_game, params: [:player_ids] },
        { type: :start_turn, params: [:player_id] },
        { type: :setup_dices, params: [:dices] },
        { type: :choose_move, params: [:move_opt_index] },
        { type: :stop_turn }
      ].each { |type:, params: []| define_action(type, params) }
    end
  end
end

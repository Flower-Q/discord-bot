require_relative '../../lib/slot_game'

class Slot
  class State
    # @return [Array<Integer>]
    attr_accessor :bet_stack

    # @return [Integer, nil]
    attr_accessor :gold

    # @return [Integer, nil]
    attr_accessor :delta

    # @return [SlotGame]
    attr_accessor :game

    # @return [true, false]
    attr_accessor :slot_updated

    # @return [true, false]
    attr_accessor :values_updated

    # @return [true, false]
    attr_accessor :timeout

    # @return [true, false]
    attr_accessor :quit

    def initialize
      @bet_stack = [1]
      @gold = nil
      @delta = nil
      @game = SlotGame.new
      @slot_updated = false
      @values_updated = false
      @quit = false
      @timeout = false
    end

    def bet
      @bet_stack.first
    end
  end

  class Reducer
    class << self
      def increase_bet(state)
        increase = case state.bet_stack.first
                   when 1...5 then 1
                   when 5...50 then 5
                   else 10
                   end

        state.bet_stack.unshift(state.bet_stack.first + increase)

        state.slot_updated = false
        state.values_updated = true
      end

      def decrease_bet(state)
        if state.bet_stack.first == 1
          state.values_updated = false
        else
          state.bet_stack.shift
          state.values_updated = true
        end

        state.slot_updated = false
      end

      def update_gold(state, gold:, delta: nil)
        if state.gold == gold && state.delta == delta
          state.values_updated = false
        else
          state.gold = gold
          state.delta = delta unless delta.nil?
          state.values_updated = true
        end

        state.slot_updated = false
      end

      def before_spin(state)
        state.game = SlotGame.new

        state.values_updated = false
        state.slot_updated = true
      end

      def spin(state, reels:)
        state.game.spin(reels)

        state.values_updated = false
        state.slot_updated = true
      end

      def timed_out(state)
        state.timeout = true
        state.quit = true
      end

      def close(state)
        state.quit = true
      end
    end

    REDUCER = lambda do |state, action|
      case action[:type]
      when :increase_bet
        increase_bet(state)
      when :decrease_bet
        decrease_bet(state)
      when :set_gold, :update_gold
        update_gold(state, action[:payload])
      when :before_spin
        before_spin(state)
      when :spin
        spin(state, action[:payload])
      when :timed_out
        timed_out(state)
      when :close
        close(state)
      else
        state = State.new
      end

      state
    end
  end
end

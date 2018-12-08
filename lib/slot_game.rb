class SlotGame
  SYMBOLS = %w[
    :bear:
    :bird:
    :butterfly:
    :cat:
    :dog:
    :dolphin:
    :frog:
    :octopus:
    :pig:
    :tiger:
  ].freeze

  def initialize
    @reels = Array.new(3) { SYMBOLS.shuffle }
  end

  # @return [Array<Array<Symbol>>]
  def lines
    @reels.transpose.first(3)
  end

  def spin(reels = @reels.size)
    @reels.last(reels).map(&:rotate!)
  end

  # @return [1, 2, 3]
  def identical_symbols
    line = @reels.transpose[1]
    line.map { |symbol| line.count(symbol) }.max
  end
end

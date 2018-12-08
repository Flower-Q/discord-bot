class SlotGameHelper
  class << self
    BLACK = ':black_large_square:'.freeze
    WHITE = ':white_small_square:'.freeze
    LINE_SEPARATOR = "\n#{BLACK * 7}\n".freeze
    private_constant :BLACK, :WHITE, :LINE_SEPARATOR

    def map_to_embed_content(slot_game)
      lines = slot_game.lines
                       .map { |line| BLACK + line.join(WHITE) + BLACK }
                       .join(LINE_SEPARATOR)

      LINE_SEPARATOR + lines + LINE_SEPARATOR
    end
  end
end

class CantStop
  BACKGROUND = "\u{25AA}".freeze
  private_constant :BACKGROUND

  NUMBERS = %W[
    1\u{20E3}
    2\u{20E3}
    3\u{20E3}
    4\u{20E3}
    5\u{20E3}
    6\u{20E3}
    7\u{20E3}
    8\u{20E3}
    9\u{20E3}
    \u{1F51F}
    \u{23F8}
    \u{1F1F0}
  ].freeze
  private_constant :NUMBERS

  DICE = "\u{1F3B2}".freeze
  private_constant :DICE

  CROSS = "\u{274C}".freeze
  private_constant :CROSS

  REACTIONS = [*NUMBERS[0..5], DICE, CROSS].freeze
  private_constant :REACTIONS

  NO_MARKERS = "\u{25FD}".freeze
  private_constant :NO_MARKERS

  NEUTRAL_MARKER = "\u{26AB}".freeze
  private_constant :NEUTRAL_MARKER

  PLAYER_MARKERS = %W[
    \u{1F535} \u{1F534} \u{1F49A} \u{1F49C}
  ].freeze
  private_constant :PLAYER_MARKERS
end

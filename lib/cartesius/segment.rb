require('cartesius/point')
require('cartesius/line')

module Cartesius

  class Segment
    extend Forwardable
    attr_reader :extreme1, :extreme2
    def_delegators(:@line, :horizontal?, :vertical?, :inclined?, :ascending?, :descending?)

    def initialize(extreme1:, extreme2:)
      @extreme1, @extreme2 = extreme1, extreme2
      validation
      @line = Line.by_points(point1: @extreme1, point2: @extreme2)
    end

    def to_line
      @line
    end

    def length
      Point.distance(@extreme1, @extreme2)
    end

    def mid
      Point.new(
          x: Rational(@extreme1.x + @extreme2.x, 2),
          y: Rational(@extreme1.y + @extreme2.y, 2)
      )
    end

    def extremes
      [@extreme1, @extreme2]
    end

    def congruent?(segment)
      segment.instance_of?(Segment) and
          segment.length == self.length
    end

    def == (segment)
      unless segment.instance_of?(Segment)
        return false
      end

      (segment.extreme1 == self.extreme1 and segment.extreme2 == self.extreme2) or
          (segment.extreme1 == self.extreme2 and segment.extreme2 == self.extreme1)
    end

    private

    def validation
      if @extreme1 == @extreme2
        raise ArgumentError.new('Extremes cannot be the same!')
      end
    end

  end

end
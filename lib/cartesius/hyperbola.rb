require('cartesius/segment')
require('cartesius/determinator')
require('cartesius/numerificator')
require('cartesius/cramer')

module Cartesius

  class Hyperbola
    include Determinator, Numerificator

    RIGHT_POSITION = 1
    UP_POSITION = -1

    private_constant(:UP_POSITION)
    private_constant(:RIGHT_POSITION)

    # Conic equation type: ax^2 + by^2 + dx + ey + f = 0
    def initialize(x2:, y2:, x:, y:, k:)
      @x2_coeff, @y2_coeff, @x_coeff, @y_coeff, @k_coeff = normalize(x2, y2, x, y, k)
      validation
    end

    def self.by_definition(focus1:, focus2:, distance:)
      if focus1 == focus2
        raise ArgumentError.new('Focus points must be different!')
      end

      focal_axis = Segment.new(extreme1: focus1, extreme2: focus2)
      if focal_axis.inclined?
        raise ArgumentError.new('Focal axis must not be inclined!')
      end

      if distance >= focal_axis.length
        raise ArgumentError.new('Difference between distances must be less than focal distance!')
      end

      c2 = Rational(focal_axis.length, 2)**2
      if focal_axis.horizontal?
        a2 = Rational(distance, 2)**2
        b2 = c2 - a2
        position = RIGHT_POSITION
      else
        b2 = Rational(distance, 2)**2
        a2 = c2 - b2
        position = UP_POSITION
      end

      center = focal_axis.mid

      build_by(a2, b2, center, position)
    end

    def self.by_axes(transverse_axis:, not_transverse_axis:)
      if transverse_axis == not_transverse_axis
        raise ArgumentError.new('Axes must be different!')
      end

      if transverse_axis.inclined? || not_transverse_axis.inclined?
        raise ArgumentError.new('Axes must not be inclined!')
      end

      if transverse_axis.horizontal? && not_transverse_axis.horizontal?
        raise ArgumentError.new('Axes can not be both horizontal!')
      end

      if transverse_axis.vertical? && not_transverse_axis.vertical?
        raise ArgumentError.new('Axes can not be both vertical!')
      end

      if transverse_axis.mid != not_transverse_axis.mid
        raise ArgumentError.new('Axes must be the same mid point!')
      end

      if transverse_axis.horizontal?
        a2 = Rational(transverse_axis.length, 2)**2
        b2 = Rational(not_transverse_axis.length, 2)**2
        position = RIGHT_POSITION
      else
        a2 = Rational(not_transverse_axis.length, 2)**2
        b2 = Rational(transverse_axis.length, 2)**2
        position = UP_POSITION
      end

      center = transverse_axis.mid

      build_by(a2, b2, center, position)
    end

    def self.by_points(center:, vertex:, point:)
      if center == vertex || center == point || vertex == point
        raise ArgumentError.new('Points must be different!')
      end

      semi_axis = Segment.new(extreme1: center, extreme2: vertex)
      if semi_axis.inclined?
        raise ArgumentError.new('Vertex must be aligned with center!')
      end

      if semi_axis.horizontal?
        position = RIGHT_POSITION
      else
        position = UP_POSITION
      end

      shifted1 = Point.new(x: vertex.x - center.x, y: vertex.y - center.y)
      shifted2 = Point.new(x: point.x - center.x, y: point.y - center.y)

      begin
        alfa, beta = Cramer.solution2(
            [shifted1.x**2, -shifted1.y**2],
            [shifted2.x**2, -shifted2.y**2],
            [position, position]
        )
      rescue
        raise ArgumentError.new('Center, vertex and point are not valid!')
      end

      a2 = Rational(1, alfa)
      b2 = Rational(1, beta)

      build_by(a2, b2, center, position)
    end

    def focus1
      discriminating(
          lambda {Point.new(x: center.x + c, y: center.y)},
          lambda {Point.new(x: center.x, y: center.y + c)}
      )
    end

    def focus2
      discriminating(
          lambda {Point.new(x: center.x - c, y: center.y)},
          lambda {Point.new(x: center.x, y: center.y - c)}
      )
    end

    def distance
      discriminating(lambda {2 * a}, lambda {2 * b})
    end

    def focal_axis
      Segment.new(extreme1: focus1, extreme2: focus2)
    end

    def transverse_axis
      discriminating(
          lambda {Segment.new(extreme1: Point.new(x: center.x - a, y: center.y), extreme2: Point.new(x: center.x + a, y: center.y))},
          lambda {Segment.new(extreme1: Point.new(x: center.x, y: center.y - b), extreme2: Point.new(x: center.x, y: center.y + b))},
      )
    end

    def not_transverse_axis
      discriminating(
          lambda {Segment.new(extreme1: Point.new(x: center.x, y: center.y - b), extreme2: Point.new(x: center.x, y: center.y + b))},
          lambda {Segment.new(extreme1: Point.new(x: center.x - a, y: center.y), extreme2: Point.new(x: center.x + a, y: center.y))}
      )
    end

    def vertices
      discriminating(
          lambda {[Point.new(x: center.x - a, y: center.y), Point.new(x: center.x + a, y: center.y)]},
          lambda {[Point.new(x: center.x, y: center.y - b), Point.new(x: center.x, y: center.y + b)]}
      )
    end

    def eccentricity
      Rational(focal_axis.length, transverse_axis.length)
    end

    def ascending_asymptote
      Line.create(slope: Rational(b, a), known_term: center.y - center.x * Rational(b, a))
    end

    def descending_asymptote
      Line.create(slope: -Rational(b, a), known_term: center.y + center.x * Rational(b, a))
    end

    def equilateral?
      a2 == b2
    end

    def congruent?(hyperbola)
      hyperbola.instance_of?(self.class) &&
          hyperbola.eccentricity == eccentricity
    end

    def == (hyperbola)
      hyperbola.instance_of?(self.class) &&
          hyperbola.focus1 == focus1 && hyperbola.focus2 == focus2 && hyperbola.distance == distance
    end

    def self.build_by(a2, b2, center, position)
      new(x2: b2, y2: -a2, x: -2 * b2 * center.x, y: 2 * a2 * center.y, k: b2 * center.x ** 2 - a2 * center.y ** 2 + -position * a2 * b2)
    end

    private_class_method(:build_by)

    private

    def validation
      if signum(@x2_coeff * @y2_coeff) >= 0 || determinator == @k_coeff
        raise ArgumentError.new('Invalid coefficients!')
      end
    end

    def discriminating(horizontal_focus_type, vertical_focus_type)
      if signum(determinator - @k_coeff) == 1
        horizontal_focus_type.call
      else
        vertical_focus_type.call
      end
    end

    def a
      Math.sqrt(a2)
    end

    def b
      Math.sqrt(b2)
    end

    def c
      Math.sqrt(a2 + b2)
    end

  end

end
require('cartesius/line')
require('cartesius/determinator')
require('cartesius/numerificator')
require('cartesius/cramer')

module Cartesius

  class Circumference
    include Determinator, Numerificator

    # Conic
    # Conic equation type: x^2 + y^2 + dx + ey + f = 0
    def initialize(x:, y:, k:)
      @x2_coeff, @y2_coeff, @x_coeff, @y_coeff, @k_coeff = normalize(1, 1, x, y, k)
      validation
    end

    def self.by_definition(center:, radius:)
      if radius <= 0
        raise ArgumentError.new('Radius must be positive!')
      end

      build_by(center, radius)
    end

    def self.by_diameter(diameter:)
      center = diameter.mid
      radius = Rational(diameter.length, 2)

      build_by(center, radius)
    end

    def self.by_points(point1:, point2:, point3:)
      alfa, beta, gamma = Cramer.solution3(
          [point1.x, point1.y, 1],
          [point2.x, point2.y, 1],
          [point3.x, point3.y, 1],
          [-(point1.x ** 2 + point1.y ** 2), -(point2.x ** 2 + point2.y ** 2), -(point3.x ** 2 + point3.y ** 2)]
      )
      new(x: alfa, y: beta, k: gamma)
    rescue
      raise ArgumentError.new('Invalid points!')
    end

    def self.goniometric
      build_by(Point.origin, 1)
    end

    def goniometric?
      self == Circumference.goniometric
    end

    def radius
      Math.sqrt(a2)
    end

    def eccentricity
      0
    end

    def congruent?(circumference)
      circumference.instance_of?(self.class) &&
          circumference.radius == radius
    end

    def == (circumference)
      circumference.instance_of?(self.class) &&
          circumference.center == center && circumference.radius == radius
    end

    def self.build_by(center, radius)
      new(x: -2 * center.x, y: -2 * center.y, k: center.x ** 2 + center.y ** 2 - radius.to_r ** 2)
    end

    private_class_method(:build_by)

    private

    def validation
      if determinator <= @k_coeff
        raise ArgumentError.new('Invalid coefficients!')
      end
    end

  end
end
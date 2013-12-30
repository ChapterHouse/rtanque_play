class Numeric

  def limit(x, y)
    if y.is_a?(Numeric)
      [[x, self].max, y].min
    elsif y == :min
      [x, self].max
    elsif y == :max
      [x, self].min
    else
      raise ArgumentError.new("Unknown limiter #{y.inspect}")
    end
  end

end

require 'matrix'

module Positionable

  attr_reader :x, :y, :vector, :time

  def vector
    @vector
  end

  def distance(other)
    if other.respond_to?(:vector)
      Math.sqrt((vector[0] - other.vector[0])**2 + (vector[1] - other.vector[1])**2)
    elsif other.respond_to?(:x) && other.respond_to?(:y)
      Math.sqrt((x - location.x)**2 + (y - location.y)**2)
    else
      raise ArgumentError.new("cannot determine distance to #{other.inspect}")
    end

  end

  private

  def x=(new_x)
    @x = new_x
    @vector = Vector[x, y]
  end

  def y=(new_y)
    @y = new_y
    @vector = Vector[x, y]
  end

  def vector=(new_vector)
    @vector = new_vector
    @x = vector[0]
    @y = vector[1]
  end

end

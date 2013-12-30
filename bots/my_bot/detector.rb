class Detector

  attr_reader :something, :time, :x, :y

  def initialize(tank)
    @time = tank.time
    @x = tank.x
    @y = tank.y
    @something = tank.radar_heading
  end

end



class Numeric

  def degrees
    self * 180 / Math::PI
  end

end
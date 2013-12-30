class Bouncer3 < RTanque::Bot::Brain
  NAME = 'bouncer3'
  include RTanque::Bot::BrainHelper

  def initialize(*args)
    @speed = MAX_BOT_SPEED
    @north_east = 45 * Math::PI / 180
    @east = 90 * Math::PI / 180
    @west = 270 * Math::PI / 180
    @heading = @west
    super
  end

  def tick!

    if sensors.speed == MAX_BOT_SPEED
      @speed = 0
    elsif sensors.speed == 0
      @speed = MAX_BOT_SPEED
    end

    if sensors.position.x <= 100
      @heading = @east
    elsif sensors.position.x >= arena.width - 100
      @heading = @west
    elsif sensors.position.y <= 100#arena.height - 100
      @heading = @north_east
    end

    self.command.speed = @speed
    self.command.heading = @heading

  end
end

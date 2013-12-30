class Bouncer < RTanque::Bot::Brain
  NAME = 'bouncer'
  include RTanque::Bot::BrainHelper

  def initialize(*args)
    @speed = MAX_BOT_SPEED
    super
  end

  def tick!
    #self.command.heading = 90 * Math::PI / 180
    #
    #if sensors.position.x <= 100
    #  @speed = MAX_BOT_SPEED
    #elsif sensors.position.x >= arena.width - 100
    #  @speed = -MAX_BOT_SPEED
    #end
    #
    #self.command.speed = @speed

    #puts "B #{sensors.ticks}: #{sensors.position.x} #{sensors.position.y}"

    # Crazy movements!
    #if sensors.ticks % 100 == 0
    #  @heading = [90, 180].shuffle.first
    #end

    @heading ||= 9
    @heading = 90 * Math::PI / 180

    self.command.heading = @heading

    if sensors.position.x <= 100
      @speed = MAX_BOT_SPEED
    elsif sensors.position.x >= arena.width - 100
      @speed = -MAX_BOT_SPEED
    end

    self.command.speed = @speed
  end
end

class Bouncer2 < RTanque::Bot::Brain
  NAME = 'bouncer2'
  include RTanque::Bot::BrainHelper

  def initialize(*args)
    @speed = MAX_BOT_SPEED
    super
  end

  def tick!
    self.command.heading = 0

    if sensors.position.y <= 100
      @speed = MAX_BOT_SPEED
    elsif sensors.position.y >= arena.height - 100
      @speed = -MAX_BOT_SPEED
    end

    self.command.speed = @speed
  end
end

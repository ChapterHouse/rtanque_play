class Circle < RTanque::Bot::Brain

  include RTanque::Bot::BrainHelper

  NAME = 'Circle'
  def tick!
    self.command.heading = self.sensors.heading + MAX_BOT_ROTATION
    self.command.speed = MAX_BOT_SPEED
  end
end

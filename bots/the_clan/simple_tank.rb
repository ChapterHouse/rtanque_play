require_relative 'utils'

module SimpleTank

  attr_accessor :fire_power

  include Positionable
  include RTanque::Bot::BrainHelper

  def cease_fire
    command.fire_power = nil if command
  end

  def fire_at_will
    command.fire_power = fire_power if command
  end

  def heading
    sensors ? sensors.heading.radians : 0
  end

  def heading=(new_heading)
    @cumulative_heading = nil
    @desired_heading = new_heading
  end

  def log(message)
    puts "#{time} #{message}"
  end

  def max_bot_rotation
    MAX_BOT_ROTATION
  end

  def max_bot_speed
    MAX_BOT_SPEED
  end

  def max_fire_power
    MAX_FIRE_POWER
  end

  def max_radar_rotation
    MAX_RADAR_ROTATION
  end

  def max_tank_rotation
    MAX_BOT_ROTATION
  end

  def max_turret_rotation
    MAX_TURRET_ROTATION
  end

  def radar_arc
    RTanque::Bot::Radar::VISION_RANGE
  end

  def name
    self.class.const_get('NAME')
  end

  def radar_heading
    sensors ? sensors.radar_heading.radians : 0
  end

  def radar_heading=(new_heading)
    @desired_radar_heading = new_heading
  end

  def speed
    sensors ? sensors.speed : 0
  end

  def stick
    #@cumulative_heading ? @cumulative_heading : [[-100.0, ((@desired_heading + 360) - (heading + 360)) / max_tank_rotation * 100].max, 100.0].min
    @cumulative_heading ? @cumulative_heading : (((@desired_heading + 360) - (heading + 360)) / max_tank_rotation * 100).limit(-100, 100)
  end

  def stick=(percentage)
    @desired_heading = nil
    #@cumulative_heading = [[-100.0, percentage.to_f].max, 100.0].min
    @cumulative_heading = percentage.to_f.limit(-100, 100)
  end

  def throttle
    speed / max_bot_speed * 100
  end

  def throttle=(percentage)
    @desired_throttle = percentage.to_f.limit(-100, 100)
  end

  def tick!
    send_commands
  end

  def time
    sensors ? sensors.ticks : -1
  end

  def turret_heading
    sensors ? sensors.turret_heading.radians : 0
  end

  def turret_heading=(new_heading)
    @desired_turret_heading = new_heading
  end

  def vector
    Vector[x, y]
  end

  def x
    sensors ? sensors.position.x : -1
  end

  def y
    sensors ? sensors.position.y : -1
  end

  private

  def send_commands
    if command
      command.heading = RTanque::Heading.new(@cumulative_heading ? heading + @cumulative_heading * max_tank_rotation : @desired_heading)
      command.turret_heading = @desired_turret_heading
      command.radar_heading = @desired_radar_heading
      command.speed = max_bot_speed * (@desired_throttle / 100)
    end
  end


end



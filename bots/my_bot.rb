# Acceleration in 120
# Max turn 1.5 degrees
# Max turrent turn 2.0 degrees
# Max radar turn 2.864788976 degrees
# SHots travel at 4.5 * firepower



# BOT_RADIUS
# MAX_FIRE_POWER
# MIN_FIRE_POWER
# MAX_HEALTH
# MAX_BOT_SPEED
# MAX_BOT_ROTATION
# MAX_TURRET_ROTATION
# MAX_RADAR_ROTATION

require 'bots/my_bot/hostiles'



class MyBot < RTanque::Bot::Brain

  attr_reader :hostiles, :max_radar_rotation, :max_tank_rotation, :max_turret_rotation, :max_turret_rotation, :radar_arc, :fire_power

  NAME = 'my_bot'
  include RTanque::Bot::BrainHelper

  def initialize(*args)

    @max_radar_rotation = MAX_RADAR_ROTATION
    @max_tank_rotation = MAX_BOT_ROTATION
    @max_turret_rotation = MAX_TURRET_ROTATION
    @radar_arc = RTanque::Bot::Radar::VISION_RANGE
    @hostiles = Hostiles.new(self)

    self.heading = 0
    self.radar_heading = 0
    self.turret_heading = 0
    self.throttle = 100
    @fire_power = 1#MAX_FIRE_POWER

    super
  end

  def tick!

    scan_for_targets

    if target_aquired?
      track_target
      if targeting_solution?
        fire_at_will
      else
        cease_fire
      end
    else
      cease_fire
      reaquire_target
    end

    @heading ||= 9

    self.heading = @heading

    if sensors.position.x <= 100
      self.throttle = 100
    elsif sensors.position.x >= arena.width - 100
      self.throttle = -100
    end

    @switch ||= 0
    @alter_heading ||= max_tank_rotation

    @switch -= 1


    if target_aquired?
    #  self.heading += max_tank_rotation
      if @switch <= 0
        #self.heading += (target.direction == :left ? -max_tank_rotation : max_tank_rotation)
        @alter_heading = (target.direction == :left ? -max_tank_rotation : max_tank_rotation)
        @switch = 200
      end
      self.heading += @alter_heading
    else
      self.heading += max_tank_rotation
    end

    self.heading += max_tank_rotation

    send_commands

    #self.command.heading = 9
  end

  def aquire_target
    self.target = hostiles.closest
    log "Target Aquired!" if !target.nil?
    @target_aquired = !target.nil?
  end

  def cease_fire
    command.fire_power = nil
  end

  def fire_at_will
    command.fire_power = fire_power
  end

  def heading
    sensors.heading.radians
  end

  def heading=(new_heading)
    @desired_heading = new_heading
  end

  def hostiles
    @hostiles ||= []
  end

  def log(message)
    puts "#{time} #{message}"
  end

  def name
    NAME
  end

  def radar_heading
    sensors.radar_heading.radians
  end

  def radar_heading=(new_heading)
    @desired_radar_heading = new_heading
  end

  def reaquire_target
    if target && target.direction == :left
      self.radar_heading -= max_radar_rotation
      self.turret_heading -=  max_turret_rotation
    else
      self.radar_heading += max_radar_rotation
      self.turret_heading += max_turret_rotation
    end
  end

  def scan_for_targets

    sensors.radar.each { |reflection| hostiles << reflection }

    if target
      log "Target Lost!" if target_aquired? && target.last_seen != time
      log "Target Found!" if !target_aquired? && target.last_seen == time

      @target_aquired = target.last_seen == time
      aquire_target if target.lost?(time)
    else
      aquire_target
    end

  end

  def target
    @target
  end

  def target=(new_target)
    @target = new_target
  end

  def target_aquired?
    @target_aquired
  end

  def targeting_solution?
    #log "#{target.firing_angle(fire_power) - turret_heading}"
    (turret_heading - target.firing_angle(fire_power)).abs < 0.01
    #true
  end

  def throttle
    sensors.speed / MAX_BOT_SPEED * 100
  end

  def throttle=(percentage)
    @desired_throttle = percentage.to_f
    if @desired_throttle > 100.0
      @desired_throttle = 100.0
    elsif @desired_throttle < -100.0
      @desired_throttle = -100.0
    end
  end

  def time
    sensors.ticks
  end

  def track_target
    self.radar_heading = target.bearing
    self.turret_heading = target.firing_angle(fire_power)
  end

  def turret_heading
    sensors.turret_heading.radians
  end

  def turret_heading=(new_heading)
    @desired_turret_heading = new_heading
  end

  def send_commands
    command.heading = RTanque::Heading.new(@desired_heading)
    command.turret_heading = @desired_turret_heading #RTanque::Heading.new(@desired_turret_heading)
    command.radar_heading = @desired_radar_heading #RTanque::Heading.new(@desired_radar_heading)
    command.speed = MAX_BOT_SPEED * (@desired_throttle / 100)
  end

  def x
    sensors.position.x
  end

  def y
    sensors.position.y
  end

end



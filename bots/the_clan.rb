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


require_relative 'the_clan/advanced_tank'

class TheClan < RTanque::Bot::Brain

  include AdvancedTank

  NAME = 'The Clan'

  def initialize(*args)

    self.radar_heading = 0
    self.turret_heading = 0
    self.stick = 100
    self.throttle = 100
    #self.fire_power = max_fire_power
    self.autoload_shells = true

    super

    #Hostiles.mapper << self
  end

  def tick!

    scan_for_targets

    if targetting_solution?
      fire_at_will
    else
      cease_fire
    end

    super

  end


  def target_aquired
    log "Target Aquired! #{target.name}"
    self.stick = target.direction == :right ? 100 : -100
  end

  def target_destroyed
    log "Target Destroyed! #{target.name}"
    target.dead = true
    self.stick *= -1
    #log (target.bearing - radar_heading).abs
    #log "Hostiles: #{hostiles.size}"
  end

  def target_lost_contact
    log "Target Lost Contact! #{target.name}"
    self.stick = target.direction == :right ? 100 : -100
    #log target.bearing
    #log radar_heading
    #log (target.bearing - radar_heading).abs
  end

  def target_lost
    log "Target Lost! #{target.name}"
    self.stick *= -1
    #log target.bearing
    #log radar_heading
    #log (target.bearing - radar_heading).abs
  end

  def target_reaquired
    log "Target Required! #{target.name}"
    self.stick = target.direction == :right ? 100 : -100
  end

end



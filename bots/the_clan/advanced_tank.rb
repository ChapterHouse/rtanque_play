require_relative 'simple_tank'
require_relative 'hostiles'

module AdvancedTank

  include SimpleTank

  attr_writer :autoload_shells

  def aquire_target
    self.target = hostiles.closest(self)
    if target.nil?
      @target_aquired = false
    else
      @target_aquired = true
      target_aquired
      track_target
    end
  end

  def autoload_shells?
    @autoload_shells
  end

  def fire_power
    self.fire_power = ideal_fire_power if autoload_shells?
    super
  end

  def hostiles
    @hostiles ||= Hostiles.instance#(self)
  end

  def ideal_fire_power
    @power_division ||= ((arena.width + arena.height) / 2) / (max_fire_power + 1)
    #target ? [(target.distance / @power_division).to_i + 1, max_fire_power].min : 0
    target ? (target.distance(self) / @power_division).to_i + 1 : 0
  end

  def scan_for_targets

    sensors.radar.each { |reflection| hostiles << Contact::Report.new(reflection.heading.radians, self, reflection.distance).to_contact(reflection.name) } if sensors
    sweep_radar

    if target
      if target_aquired?
        if !target.current?(time)
          @target_aquired = false
          if (target.bearing - radar_heading).abs < 0.001
            target_destroyed
            aquire_target
          else
            target_lost_contact
          end
        else
          track_target
        end
      else
        if target.current?(time)
          @target_aquired = true
          track_target
          target_reaquired
        elsif target.lost?(time)
          target_lost
          aquire_target
        end
      end
    else
      aquire_target
    end

  end

  def sweep_radar
    if target && target.direction == :left
      self.radar_heading -= max_radar_rotation
      self.turret_heading -=  max_turret_rotation
    else
      self.radar_heading += max_radar_rotation
      self.turret_heading += max_turret_rotation
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

  def targetting_solution?
    if target_aquired?
      target.targetting_arc(self).include?(turret_heading)
    else
      false
    end
    #target_aquired? && (turret_heading - target.firing_angle(fire_power)).abs < 0.1
  end

  def track_target
    self.radar_heading = target.bearing
    self.turret_heading = target.firing_angle(self) || target.bearing
  end

end



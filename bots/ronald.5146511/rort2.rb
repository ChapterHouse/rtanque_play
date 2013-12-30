class Rort2 < RTanque::Bot::Brain
  include RTanque::Bot::BrainHelper

  NAME = self.to_s
  TURRET_FIRE_RANGE = RTanque::Heading::ONE_DEGREE * 15.0
  WALL_DETECTION_DISTANCE = 50
  
  def tick!
    check_hit!
    @friendly_fire = true if sensors.button_down?('f')
    
    if (target = get_nearest_target)
      fire_on(target)
    else
      seek_target
    end

    command.speed = RTanque::Bot::MAX_SPEED

    new_heading = if hit?
     sensors.heading + RTanque::Heading::EIGHTH_ANGLE
    elsif near?(:top)
      RTanque::Heading::SE
    elsif near?(:right)
      RTanque::Heading::SW
    elsif near?(:bottom)
      RTanque::Heading::NW
    elsif near?(:left)
      RTanque::Heading::NE
    end
    if new_heading
      @target_heading = new_heading
    end
    command.heading = @target_heading
  end

  def seek_target
    command.radar_heading = sensors.radar_heading + MAX_RADAR_ROTATION
    command.turret_heading = sensors.radar_heading
  end

  def get_nearest_target
    reflections = sensors.radar
    reflections = reflections.reject{|r| r.name == NAME } unless @friendly_fire
    target = reflections.sort_by{|r| r.distance }.first
    @turret_heading = if @last_position && target
      current_position = sensors.position.move(target.heading, target.distance)
      unless current_position == @last_position
        h = @last_position.heading(current_position)
        s = sensors.position.distance(current_position) / RTanque::Shell::SHELL_SPEED_FACTOR / 2 
        estimated_position = current_position.move(h, s)
        sensors.position.heading(estimated_position)
      end
    end
    if target
      @last_position = sensors.position.move(target.heading, target.distance)
    end
    target
  end
  
  def near?(wall)
    case wall
      when :top
        sensors.position.y + WALL_DETECTION_DISTANCE >= self.arena.height
      when :right
        sensors.position.x + WALL_DETECTION_DISTANCE >= self.arena.width
      when :bottom
        sensors.position.y - WALL_DETECTION_DISTANCE <= 0
      when :left
        sensors.position.x - WALL_DETECTION_DISTANCE <= 0
      else
        false
    end
  end
  
  def check_hit!
    @hit_check = (@last_health && @last_health != sensors.health).tap do |h|
      # code from the time before health bar :-)
      # print "\nhit:#{sensors.health.round} @ #{sensors.ticks}" if h
    end
    @last_health = sensors.health
  end
  
  def hit?
    @hit_check
  end
  
  def fire_on(reflection)
    command.radar_heading = reflection.heading
    command.turret_heading = @turret_heading || reflection.heading
    # credits to Seek&Destroy
    if (reflection.heading.delta(sensors.turret_heading)).abs < TURRET_FIRE_RANGE
      command.fire(reflection.distance > 200 ? MAX_FIRE_POWER : MIN_FIRE_POWER)
    end
  end
end
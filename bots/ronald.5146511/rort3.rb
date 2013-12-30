class Rort3 < RTanque::Bot::Brain
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

    change_angle = hit? ? RTanque::Heading::EIGHTH_ANGLE : angle_from_wall
    if change_angle
      @target_heading = sensors.heading + change_angle
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
  
  def near_wall?(wall)
    case wall
     when :top, RTanque::Heading::N
        sensors.position.y + WALL_DETECTION_DISTANCE >= arena.height
      when :right, RTanque::Heading::E
        sensors.position.x + WALL_DETECTION_DISTANCE >= arena.width
      when :bottom, RTanque::Heading::S
        sensors.position.y - WALL_DETECTION_DISTANCE <= 0
      when :left, RTanque::Heading::W
        sensors.position.x - WALL_DETECTION_DISTANCE <= 0
      else
        false
    end
  end
  
  DIRECTIONS = %w[N E S W].map{|s| RTanque::Heading.const_get(s) }
  RANGE_LEFT  = -RTanque::Heading::HALF_ANGLE..0
  RANGE_RIGHT =  0..RTanque::Heading::HALF_ANGLE 
  def angle_from_wall
    if current_wall_direction = DIRECTIONS.detect{|d| near_wall?(d) }
      # normalize angle 
      a = sensors.heading.to_f - current_wall_direction
      a -= RTanque::Heading::FULL_ANGLE if a > RTanque::Heading::S
      a += RTanque::Heading::FULL_ANGLE if a < -RTanque::Heading::S
      turn_left_or_right = case a
        when RANGE_LEFT
          -1
        when RANGE_RIGHT
          1
        else
          raise  "unsupported angle #{a.inspect}"
      end
      return RTanque::Heading::EIGHTH_ANGLE * turn_left_or_right 
    end
    nil
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
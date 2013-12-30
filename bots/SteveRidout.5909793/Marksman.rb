class Marksman < RTanque::Bot::Brain
  NAME = 'Marksman'
  include RTanque::Bot::BrainHelper

  def tick!
    command.speed = RTanque::Bot::MAX_SPEED
    nearest = nearest_target()

    if (!defined?(@direction))
      @direction = 0
      @previousTargetX = 0
      @previousTargetY = 0
    end

    if (nearest)
        targetX = sensors.position.x + Math.sin(nearest.heading) * nearest.distance
        targetY = sensors.position.y + Math.cos(nearest.heading) * nearest.distance

        power = RTanque::Bot::MAX_FIRE_POWER

        predictedTargetX = targetX + (targetX - @previousTargetX) * nearest.distance / (5.0 * power)
        predictedTargetY = targetY + (targetY - @previousTargetY) * nearest.distance / (5.0 * power)

        deltaX = predictedTargetX - sensors.position.x
        deltaY = predictedTargetY - sensors.position.y

        tan = deltaX / deltaY
        if (deltaX > 0 && deltaY > 0)
          angle = Math.atan(tan)
        elsif (deltaX > 0 && deltaY < 0)
          angle = Math::PI - Math.atan(-tan)
        elsif (deltaX < 0 && deltaY > 0)
          angle = Math::PI * 2 - Math.atan(-tan)
        elsif (deltaX < 0 && deltaY < 0)
          angle = Math::PI + Math.atan(tan)
        end

        @previousTargetX = targetX
        @previousTargetY = targetY

        command.radar_heading = nearest.heading
        command.turret_heading = angle
        command.fire(power)
    else
        command.radar_heading = sensors.radar_heading + RTanque::Heading::ONE_DEGREE * 10.0
    end

    onWall = false
    if (sensors.position.on_top_wall?)
        command.heading = RTanque::Heading::SOUTH
        onWall = true
    elsif (sensors.position.on_bottom_wall?)
        command.heading = RTanque::Heading::NORTH
        onWall = true
    elsif (sensors.position.on_left_wall?)
        command.heading = RTanque::Heading::EAST
        onWall = true
    elsif (sensors.position.on_right_wall?)
        command.heading = RTanque::Heading::WEST
        onWall = true
    end

    if (onWall)
      if (sensors.heading.delta(command.heading) > 0)
        @direction = 1
      else
        @direction = -1
      end
    else
        if (Random.rand(80) < 1)
            @direction = 0 - @direction
        end

        command.heading = sensors.heading + @direction * RTanque::Heading::ONE_DEGREE * 5.0
    end
  end

  # this function borrowed from rort1.rb (https://gist.github.com/ronald/5146511)
  def nearest_target
    reflections = sensors.radar
    reflections = reflections.reject{|r| r.name == NAME } unless @friendly_fire
    reflections.sort_by{|r| r.distance }.first
  end
end

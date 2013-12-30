class Contact

  require_relative 'contact/position'

  include RTanque::Bot::BrainHelper

  attr_reader :name
  attr_reader :positions
  attr_writer :dead

  def initialize(name, position)
    @name = name.dup
    @positions = [position]
    @dead = false
  end

  def ==(other)
    (other.is_a?(Contact) && name == other.name) && (time == other.time && distance(other) < 0.1 ||  (other.time - time).abs == 1 && distance(other) <= 3.0)
  end

  def acceleration
    speed(0) - speed(1)
  end

  def alive?
    !dead?
  end

  def cache
    if @cache_time != time
      @cache_time = time
      @cache = {}
    end
    @cache
  end

  def current?(current_time)
    current_time == last_seen
  end

  def dead?
    @dead
  end

  def delta(measurement, ago=0)
    rv = previous(measurement, ago) - previous(measurement, ago + 1)
    (measurement == :bearing) && (rv > 180) ? (360 - rv) : rv
  end

  def direction(ago=0)
    (bearing(ago) - bearing(ago + 1)) >= 0 ? :right : :left
  end


  #def distance_from(other)
  #  Math.sqrt((x - other.x)**2 + (y - other.y)**2)
  #end

  def heading(ago=0)
    Math.atan2(x(ago) - x(ago + 1), y(ago) - y(ago + 1))
  end

  def firing_angle(tank)
    unless cache.has_key?(:firing_angle)
      #positionB = Vector[position.detection_x, position.detection_y]
      target_position = Vector[x, y]
      dirT = Vector[Math.sin(heading), Math.cos(heading)]
      speedB = 4.5 * tank.fire_power
      speedT = speed
      posIntercept = point_of_intercept(tank.vector, target_position, dirT, speedB, speedT)

      if posIntercept
        # TODO: Make the contraints trigger off of arena
        #intercept = Vector[[[0, posIntercept[0]].max, 1200].min, [[0, posIntercept[1]].max, 700].min]
        intercept = Vector[posIntercept[0].limit(0, 1200), posIntercept[1].limit(0, 700)]
        cache[:firing_angle] = (Math.atan2(intercept[0] - tank.x, intercept[1] - tank.y) + 2 * Math::PI) % (2 * Math::PI)
      else
        cache[:firing_angle] = nil
      end
    end
    cache[:firing_angle]
  end

  def lateral_acceleration
    lateral_velocity(0) - lateral_velocity(1)
  end

  def lateral_velocity(ago=0)
    speed * Math.sin(bearing(ago) - heading(ago))
  end

  def lost?(current_time)
    current_time - last_seen > 180
  end

  #Vector positionB - Postition of Bullet
  #Vector positionT - Postition of Target
  #Vector dirT - Unit Direction of Target travel
  #float speedB - Speed of Bullet
  #float speedT - Speed of Target
  def point_of_intercept(positionB, positionT, dirT, speedB, speedT)

    if speedB <= 0
      nil
    elsif speedT == 0
      positionT
    elsif speedB == speedT
      positionDiff = (positionB - positionT)
      positionDiffNorm = positionDiff.normalize
      scalar = positionDiffNorm.inner_product(dirT)
      if scaler >= 0
        shotDir = dirT - (2 * scalar * positionDiffNorm)
        velDiff = (dirT * speedT) - (shotDir * speedB)
        shotDir * ((positionDiff*velDiff) / (velDiff**2))
      else
        nil
      end
    else
      velocityT = dirT * speedT
      a = velocityT.inner_product(velocityT) - speedB**2
      unless a == 0
        toTarg = positionT - positionB
        b = 2*(velocityT.inner_product(toTarg))
        c = toTarg.inner_product(toTarg)
        radicand = b**2 - 4*a*c
        if radicand >= 0
          sqrtRadicand = Math.sqrt(radicand)
          denominator = 2*a
          intercept_time = [(-b + sqrtRadicand) / denominator, (-b - sqrtRadicand) / denominator].sort.delete_if { |x| x < 0 }.first
          intercept_time ? positionT + (velocityT * intercept_time) : nil
        else
          nil
        end
      else
        nil
      end
    end
  end

  def position(ago=0)
    positions[ago] || positions.first
  end

  def respond_to?(method_name)
    mname = method_name.to_s
    super || mname[0..8] == 'previous_' || mname[-6..-1] == '_delta' || position.respond_to?(method_name)
  end

  def speed(ago=0)
    # r = d/t is real easy when t is always 1
    Math.sqrt((x(ago) - x(ago + 1))**2 + (y(ago) - y(ago + 1))**2)
  end

  def last_seen
    time
  end

  def previous(measurement, ago=1)
    position(ago).send(measurement)
  end

  def simple_firing_angle(fire_power)
    begin
      latv = lateral_velocity
      latv = 0 if latv > MAX_BOT_SPEED || latv < -MAX_BOT_SPEED
      (bearing - Math.asin(latv / (4.5 * fire_power))) % (2 * Math::PI)
    rescue Math::DomainError
      nil #Float::INFINITY
    end

  end

  def targetting_arc(tank)
    angle = firing_angle(tank)
    angular_radius = (BOT_RADIUS * 2 / distance(tank)) / 2
    angle ? ((angle - angular_radius)..(angle + angular_radius)) : (-1..-1)
    #((bearing - angular_diameter / 2)..(bearing + angular_diameter / 2))
  end

  def to_s
    "#{name} #{distance} #{bearing}"
  end

  def update(contact_position)
    if contact_position.time == time
      contact_position.reports.each { |report| position.add_report(report) }
    else
      positions.unshift contact_position
    end
  end



  private

  attr_accessor :last_x, :last_y

  def method_missing(method_name, *args, &block)
    mname = method_name.to_s
    if mname[0..8] == 'previous_'
      previous(mname[9..-1].to_sym, *args, &block)
    elsif mname[-6..-1] == '_delta'
      delta(mname[0..-7].to_sym, *args, &block)
    elsif position.respond_to?(method_name)
      ago = args.first.is_a?(Fixnum) ? args.shift : 0
      position(ago).send(method_name, *args, &block)
    else
      begin
        super
      rescue Exception => e
        location = File.expand_path(__FILE__)
        backtrace = e.backtrace.select do |line|
          match = /(.*?):\d+:in .method_missing'$/.match(line)
          match.nil? || File.expand_path(match[1]) != location
        end
        e.set_backtrace(backtrace)
        raise e
      end
    end
  end

end


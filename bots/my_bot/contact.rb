class Contact

  include Comparable
  include RTanque::Bot::BrainHelper

  attr_reader :bdelta, :ddelta, :name, :distance, :bearing, :detector

  def initialize(reflection, detector)
    @name = reflection.name.dup
    @distance = reflection.distance
    @bearing = reflection.heading.radians
    @detector = detector
    @ddelta = 0
    @bdelta = 0
    @last_x = x
    @last_y = y
  end

  def something
    detector.something
  end

  def heading
    Math.atan2(x - last_x, y - last_y)
  end

  def firing_angle(fire_power)
    begin
      (bearing - Math.asin(lateral_velocity / (4.5 * fire_power))) % (2 * Math::PI)
    rescue Math::DomainError
    #  puts "CRAP!"
      0
    end
  end

  def lateral_velocity
    speed * Math.sin(bearing - heading)
  end

  def speed
    # r = d/t is real easy when t is always 1
    Math.sqrt((x - last_x)**2 + (y - last_y)**2)
  end

  def last_seen
    time
  end

  def x
    distance * Math.sin(bearing) + detector.x
  end

  def y
    distance * Math.cos(bearing) + detector.y
  end

  def update(contact)
    if contact == self
      if contact.time == time + 1
        @last_x = x
        @last_y = y
      else
        @last_x = contact.x
        @last_y = contact.y
      end
      @ddelta = contact.distance - distance
      @bdelta = contact.bearing - bearing
      @distance = contact.distance
      @bearing = contact.bearing
      @detector = contact.detector
    end
  end

  def ==(other)
    other.respond_to?(:name) && (name == other.name)
  end

  def <=>(other)
    distance <=> other.distance
  end

  def direction
    bdelta >= 0 ? :right : :left
  end

  def lost?(current_time)
    current_time - last_seen > 180
  end

  def targeting_arc
    angular_diameter = (BOT_RADIUS * 2 / distance)
    ((bearing - angular_diameter)..(bearing + angular_diameter))
  end

  def time
    detector.time
  end

  def to_s
    "#{name} #{distance} #{bearing}"
  end

  private

  attr_accessor :last_x, :last_y

end

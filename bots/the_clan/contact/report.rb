class Contact::Report

  include Positionable

  attr_reader :bearing, :detector

  def initialize(bearing, detector, detector_distance)
    @detector = detector
    @bearing = bearing
    self.x = detector_distance * Math.sin(bearing) + detector.x
    self.y = detector_distance * Math.cos(bearing) + detector.y
    @time = detector.time
    #@location = Location.new(distance * Math.sin(bearing) + detector.x, distance * Math.cos(bearing) + detector.y, detector.time)
  end

  def to_contact(name)
    to_position.to_contact(name)
  end

  def to_position
    Contact::Position.new(self)
  end

end
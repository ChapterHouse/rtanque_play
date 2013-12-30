require 'bots/my_bot/contact'
require 'bots/my_bot/detector'

class Hostiles < Array

  def initialize(tank)
    @tank = tank
  end

  def <<(contact)
    contact = update(contact)
    contact ? super(contact) : self
  end

  def closest
    sort.find { |contact| !contact.lost?(time) }
  end

  def find(target)
    target && super() { |contact| contact == target }
  end

  def push(contact)
    contact = update(contact)
    contact ? super(contact) : self
  end

  def unshift(contact)
    contact = update(contact)
    contact ? super(contact) : self
  end

  private

  attr_reader :tank

  #def bearing
  #  tank.radar_heading
  #end

  def convert(object)
    if object.respond_to?(:name) && object.name == tank.name
      nil
    elsif object.is_a?(RTanque::Bot::Radar::Reflection)
      Contact.new(object, Detector.new(tank))
    elsif object.is_a?(Contect)
      object
    else
      nil
    end
  end

  def time
    tank.time
  end

  def update(object)
    contact = convert(object)
    known_contact = find(contact)
    if known_contact
      known_contact.update(contact)
      contact = nil
    end
    contact
  end

end

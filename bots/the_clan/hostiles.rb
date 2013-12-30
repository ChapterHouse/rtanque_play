require_relative 'contact'
require 'singleton'


class Hostiles < Array

  include Singleton

  def <<(contact)
    @time = contact.time
    contact = update(contact)
    contact ? super(contact) : self
  end

  def closest(tank)
    @time = tank.time
    closest_to(tank, current(tank.time))
    #Array(current(tank.time).map { |contact| [contact.distance(tank), contact] }.sort { |a, b| a.first <=> b.first }.first).last
  end

  def current(time)
    select { |contact| contact.alive? && contact.current?(time) }
  end

  def log(message)
    puts "#{time} #{message}"
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

  def closest_to(tank, candidates)
    Array(candidates.map { |contact| [contact.distance(tank), contact] }.sort { |a, b| a.first <=> b.first }.first).last
  end

  def similar_to(tank)
    select { |candidate| tank == candidate }
  end

  def most_likely_is(tank)
    #select { |candidate| tank.name == candidate.name }.first
    closest_to(tank, similar_to(tank))
  end

  def update(contact)
    known_contact = most_likely_is(contact)
    if known_contact
      #puts contact.distance(known_contact)
      known_contact.update(contact.position)
      contact = nil
    else
      log "New contact #{contact.name} #{contact.x} #{contact.y}"
    end
    contact
  end

  private

  def time
    @time ||= -1
  end

end


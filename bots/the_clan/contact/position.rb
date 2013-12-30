require_relative 'report'

class Contact::Position

  attr_reader :bearing

  include Positionable

  def initialize(reports)
    @reports = Array(reports)
    update_details
  end

  def add_report(report)
    if report.time > time
      @reports = Array(report)
      update_details
    elsif report.time == time
      @reports << report
      update_details
    end
  end

  def to_contact(name)
    Contact.new(name, self)
  end

  attr_reader :reports

  private

  def update_details
    @time = reports.first.time
    self.vector = reports.inject(Vector[0, 0]) { |v, report| v + report.vector } / reports.size
    @bearing = reports.inject(0) { |b, report| b + report.bearing } / reports.size
  end

end
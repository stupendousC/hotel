require_relative 'lib_requirements.rb'

class Reservation
  include Helpers
  attr_reader :id, :cost, :room_id, :date_range, :start_date, :end_date, :new_nightly_rate

  def initialize(room_id:, date_range:, new_nightly_rate: nil)
    # ASSUMING: have validated room_id before now
    # Should've validated date availability vs. room before this step

    @room_id = room_id
    
    unless date_range.class != Date_range
      @date_range = date_range
      @start_date = @date_range.start_date
      @end_date = @date_range.end_date
    else 
      raise ArgumentError, "Date_range object required"
    end
    
    # will need to override if Block is in effect
    @new_nightly_rate = new_nightly_rate
    
    @id = self.generate_id
    @cost = nil
  end

  class << self
    attr_reader :available_id
    @@available_id = 1000

    def generate_id
    @@available_id += 1
    return @@available_id
    end
  end

  

  def calc_cost
  end

end
require_relative 'lib_requirements.rb'

class Reservation
  include Helpers
  attr_reader :id, :cost, :room_id, :date_range, :start_date, :end_date, :new_nightly_rate

  def initialize(room_id:, date_range:, new_nightly_rate: nil)
    # ASSUMING: have validated room_id before now
    # ASSUMING: Should've validated date availability vs. room before this step

    @room_id = room_id
    
    unless date_range.class != Date_range
      @date_range = date_range
      @start_date = @date_range.start_date
      @end_date = @date_range.end_date
    else 
      raise ArgumentError, "Date_range object required"
    end
    
    # TODO: will need to double check if Block is in effect, make sure rates agree
    if new_nightly_rate 
      if new_nightly_rate.class != Integer
        raise ArgumentError, "New_nightly_rate must be an Integer"
      elsif non_zero_integer? new_nightly_rate
        @new_nightly_rate = new_nightly_rate
      else
        raise ArgumentError, "New_nightly_rate must be a non-zero Integer"
      end
    end
    
    @id = Reservation.generate_id
    @cost = nil
  end

  


  def calc_cost
  end
  


  class << self
    @@available_id = 1000

    def generate_id
      @@available_id += 1
      return @@available_id
    end
  end

end
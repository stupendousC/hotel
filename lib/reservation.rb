require_relative 'lib_requirements.rb'

class Reservation
  include Helpers
  attr_reader :id, :cost, :customer, :room_id, :room, :date_range, :start_date, :end_date, :new_nightly_rate

  def initialize(room_id:, room:nil, date_range:, customer:, new_nightly_rate: nil)
    # all arg validations done by precursor method Hotel_front_desk#make_reservation

    @room_id = room_id
    if room
      @room = room
    end
    
    unless date_range.class != Date_range
      @date_range = date_range
      @start_date = @date_range.start_date
      @end_date = @date_range.end_date
    else 
      raise ArgumentError, "Date_range object required"
    end
    
    # TODO? will need to double check if Block is in effect, make sure rates agree
    if new_nightly_rate
      @new_nightly_rate = new_nightly_rate
    end

    @id = Reservation.generate_id
    @cost = nil
    @customer = customer    
  end

  def calc_cost
    # Sets rate = 200/standard, unless overriding new_nightly_cost (higher/lower ok) exists
    rate = nil
    if @new_nightly_rate
      rate = @new_nightly_rate
    else
      rate = STANDARD_RATE
    end

    total_nights = (@end_date - @start_date) 

    return rate*total_nights
  end
  


  class << self
    @@available_id = 1000

    def generate_id
      @@available_id += 1
      return @@available_id
    end
  end

end

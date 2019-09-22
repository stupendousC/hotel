require_relative 'lib_requirements.rb'

class Reservation
  include Helpers
  attr_reader :id, :cost, :customer, :room_id, :room, :date_range, :start_date, :end_date, :new_nightly_rate, :block
  
  def initialize(room_id:, room:nil, date_range:, customer:, new_nightly_rate: nil, block: nil)
    # all arg validations done by precursor method HotelFrontDesk#make_reservation
    
    @room_id = room_id
    if room
      @room = room
    end
    
    @date_range = date_range
    @start_date = @date_range.start_date
    @end_date = @date_range.end_date
    
    if new_nightly_rate
      @new_nightly_rate = new_nightly_rate
    end
    
    @id = Reservation.generate_id
    @customer = customer    
    @block = block
    
    # assigning @cost
    calc_cost
  end
  
  def calc_cost
    # Sets rate = 200/standard, unless overriding new_nightly_cost (higher/lower ok) exists
    rate = nil
    if @new_nightly_rate
      rate = @new_nightly_rate
    else
      rate = STANDARD_RATE
    end
    
    total_nights = (@end_date - @start_date).to_i   
    # I had to add .to_i b/c it returns a Rational of number/1, and i only want the number
    
    @cost = rate * total_nights
    
    return @cost
  end
  
  def to_s 
    string = "Reservation ##{id} for #{customer}: Room##{room_id}, #{start_date} until #{end_date}.  Total = $#{cost}."
    if @block
      string << " *#{block}*"
    end
    return string
  end
  
  
  class << self
    @@available_id = 1000
    
    def generate_id
      @@available_id += 1
      return @@available_id
    end
  end
  
end

require_relative 'lib_requirements.rb'

class Room
  include Helpers
  attr_reader :id, :nightly_rate, :occupied_nights, :all_reservations
  # Format of @occupied_nights is SORTED, [ DateObj1, DateObj2, DateObj3, etc]
  STANDARD_RATE = 200
  
  def initialize(id: , nightly_rate: STANDARD_RATE)
    
    # validate id
    unless non_zero_integer?(id)
      raise ArgumentError, "id #{id} must be a non-zero integer"
    end
    @id = id
    
    # validate nightly_rate (not gonna bother w/ float prices)
    if (nightly_rate != STANDARD_RATE) && !(non_zero_integer?(nightly_rate))
      raise ArgumentError, "nightly_rate #{nightly_rate} must be a non-zero integer"
    end
    @nightly_rate = nightly_rate
    
    @occupied_nights = []
    @all_reservations = []
  end
  
  
  def check_avail?(date_range_obj)
    # checks all dates within the range and returns T/F
    start_date = date_range_obj.start_date
    end_date = date_range_obj.end_date
    curr_date = start_date
    while curr_date < end_date 
      # not checking end_date b/c won't stay that night anyway
      # refactor: use binary search since list is sorted
      if @occupied_nights.include? curr_date
        return false
      else
        curr_date += 1
      end
    end
    # at this point the date range is available for this Room instance
    return true
  end
  
  def make_unavail(date_range_obj)
    # adds all the date objs (EXCEPT end-date b/c checkout @ noon) from the range to @occupied_nights
    # then sort @@occupied_nights
    start_date = date_range_obj.start_date
    end_date = date_range_obj.end_date
    curr_date = start_date
    while curr_date < end_date
      @occupied_nights << curr_date
      curr_date += 1
    end

    @occupied_nights.sort!
  end

  def add_reservation(reservation_obj)
    if reservation_obj.class == Reservation 
      if reservation_obj.room_id == id
        @all_reservations << reservation_obj
      else
        raise ArgumentError, "Dafuq? That's a different room's reservation!"
      end
    else
      raise ArgumentError, "Non-Reservation obj shan't make it onto this here list"
    end
  end
  
end
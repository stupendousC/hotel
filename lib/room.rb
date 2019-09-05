require_relative 'lib_requirements.rb'

class Room
  include Helpers
  attr_reader :id, :nightly_rate, :occupied_nights
  # Format of @occupied_nights is [ DateObj1, DateObj2, DateObj3, etc]
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
  end


  def check_avail?(start_date_obj:, end_date_obj:)
    # checks all dates within the range and returns T/F
    if valid_date_range?(start_date_obj, end_date_obj)
      curr_date_obj = start_date_obj
      while curr_date_obj < end_date_obj 
        # not checking end_date b/c won't stay that night anyway
        if @occupied_nights.include? curr_date_obj
          return false
        else
          curr_date_obj += 1
          next
        end
      end
      # at this point the date range is available for this Room instance
      return true
    else
      if (start_date_obj.class != Date) || (end_date_obj.class != Date) 
        raise ArgumentError, "You must provide Date objects"
      elsif start_date_obj === end_date_obj
        raise ArgumentError, "Gross... you can't book w/o overnight stay!"
      elsif start_date_obj > end_date_obj
        raise ArgumentError, "No can do, Marty McFly!"
      end
    end
  end

  def make_unavail(start_date_obj:, end_date_obj:)
    # adds all the date objs (EXCEPT end-date b/c checkout @ noon) from the range to @occupied_nights
    
    unless valid_date_range?(start_date_obj, end_date_obj)
      raise ArgumentError, "Should've caught this at the check_avail? step, investigate!"
    end

    curr_date_obj = start_date_obj
    while curr_date_obj < end_date_obj
      @occupied_nights << curr_date_obj
      curr_date_obj += 1
    end
  end

end
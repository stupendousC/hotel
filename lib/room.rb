require_relative 'lib_requirements.rb'

class Room
  include Helpers
  attr_reader :id, :nightly_rate, :occupied_nights
  # @occupied_nights = [ Date1, Date2, Date3, etc]
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


  def check_avail(start_date_obj:, end_date_obj:)
    if valid_date_range?(start_date_obj, end_date_obj)
      # Check dates here
    else
      if (start_date_obj.class != Date) || (end_date_obj.class != Date) 
        raise ArgumentError, "You must provide Date objects"
      elsif start_date_obj === end_date_obj
        raise ArgumentError, "Gross... you cna't book w/o overnight stay!"
      elsif start_date_obj > end_date_obj
        raise ArgumentError, "No can do, Marty McFly!"
      end
    end
  end

  def make_unavail(start_date_obj:, end_date_obj:)
  end

end
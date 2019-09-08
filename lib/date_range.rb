require_relative 'lib_requirements.rb'

class Date_range
  include Helpers
  attr_reader :start_date, :end_date

  def initialize(start_date_obj:, end_date_obj:)
    # validate args
    if (start_date_obj.class != Date) || (end_date_obj.class != Date)
      raise ArgumentError, "Both args need to be Date objects"
    elsif end_date_obj == start_date_obj
      raise ArgumentError, "Gross... you can't book w/o overnight stay!"
    elsif end_date_obj < start_date_obj
      raise ArgumentError, "No can do, Marty Mcfly!"
    end
    
    @start_date = start_date_obj
    @end_date = end_date_obj
  end

  def date_in_range?(date_obj)
    # DOES NOT DIFFERENTIATE BETWEEN CHECKOUT DAYS & REGULAR DAYS
    if date_obj.class != Date
      raise ArgumentError, "You need to pass in a Date obj"
    elsif (@start_date <= date_obj) && (date_obj <= @end_date)
      return true
    else
      return false
    end
  end

  def ranges_overlap?(other_date_range)
    # ok to overlap 1st/last day with other's 1st/last day b/c checkout=noon
    if other_date_range.class != Date_range
      raise ArgumentError, "You need to pass in a Date_range obj"
    elsif (other_date_range.end_date > @start_date) && (other_date_range.end_date <= @end_date)
      return true
    elsif (other_date_range.start_date < @end_date) && (other_date_range.start_date >= @start_date)     
      return true
    else
      return false
    end
  end
end  





### DIDN'T NEED THIS, BUT I'M KEEPING IT AROUND JUST IN CASE FOR FUTURE WAVES
  # def head_clash?(potential_checkin)
  #   # use this when determining if self is the Date_range for an existing reservation,
  #   # and the arg is a date belonging to another customer's potential_checkin
  #   if potential_checkin.class != Date
  #     raise ArgumentError, "You need to pass in a Date obj"
  #   elsif (@start_date <= potential_checkin) && (potential_checkin < @end_date)
  #     return true
  #   else
  #     return false
  #   end
  # end

  # def tail_clash?(potential_checkout)
  #   # use this when determining if self is the Date_range for an existing reservation,
  #   # and the arg is a date belonging to another customer's potential_checkout
  #   if potential_checkout.class != Date
  #     raise ArgumentError, "You need to pass in a Date obj"
  #   elsif (@start_date < potential_checkout) && (potential_checkout <= @end_date)
  #     return true
  #   else
  #     return false
  #   end
  # end
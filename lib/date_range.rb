require_relative 'lib_requirements.rb'

class Date_range
  include Helpers
  attr_reader :start_date, :end_date, :all_dates, :all_nights

  def initialize(start_date_obj:, end_date_obj:)
    # validate args
    if (start_date_obj.class != Date) || (end_date_obj.class != Date)
      raise ArgumentError, "Both args need to be Date objects"
    elsif end_date_obj < start_date_obj
      raise ArgumentError, "Date range invalid"
    end
    
    @start_date = start_date_obj
    @end_date = end_date_obj
    assemble_all_dates
    @all_nights = @all_dates[0..-2]
  end

  def assemble_all_dates
    @all_dates = []
    curr_date = @start_date
    while curr_date <= @end_date
      all_dates << curr_date
      curr_date += 1
    end
  end

  def date_in_range?(date_obj)
    
  end

  def ranges_overlap?
  end
end
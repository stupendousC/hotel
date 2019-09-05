require 'time'

# any other requirements?  idk...


module Helpers
  
  def non_zero_integer?(num)
    if num.class != Integer 
      return false
    elsif num.nil? || num <= 0
      return false
    end
    return true
  end
  
  def non_blank_string?(str)
    if str.class != String
      return false
    elsif str == ""
      return false
    end
    return true
  end
  
  def available_id?(id, array_taken_ids)
    if non_zero_integer? id
      (array_taken_ids.include? id)? false : true 
    else 
      return false
    end
  end

  def valid_date_range?(start_date_obj, end_date_obj)
    # args MUST be Date objs
    if (start_date_obj.class == Date) && (end_date_obj.class == Date)
      (end_date_obj > start_date_obj) ? true : false
    else
      return false
    end
  end

end
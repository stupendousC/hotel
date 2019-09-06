require 'time'

STANDARD_RATE = 200

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
  
  # I made this for now-defunct Customer class, save for future
  def available_id?(id, array_taken_ids)
    if non_zero_integer? id
      (array_taken_ids.include? id)? false : true 
    else 
      return false
    end
  end
  
end
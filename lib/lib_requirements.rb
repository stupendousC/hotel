require 'time'

# any other requirements?  idk...


module Validation
  
  def non_zero_integer?(num)
    if num.class != Integer 
      raise ArgumentError, "#{num} must be an Integer"
    elsif num.nil? || num <= 0
      raise ArgumentError, '#{num} cannot be blank or less than zero.'
    end
    return true
  end
  
  def non_blank_string?(str)
    if str.class != String
      raise ArgumentError, '#{str} must be a String'
    elsif str == ""
      raise ArgumentError, '#{str} cannot be blank '
    end
  end

  
  
  
end
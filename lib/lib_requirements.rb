require 'time'
require 'csv'

ALL_ROOMS_CSV = "data/all_rooms.csv"
ALL_RESERVATIONS_CSV = "data/all_reservations.csv"
ALL_BLOCKS_CSV = "data/all_blocks.csv"

STANDARD_RATE = 200
MAX_BLOCK_SIZE = 5

module Helpers
  
  
  def non_zero_integer?(num)
    if num.class != Integer 
      return false
    elsif num.nil? || num <= 0
      return false
    end
    return true
  end
  
  def non_zero_dollar_float?(num)
    if (num.class != Float) && (num.class != Integer)
      return false
    elsif num.nil? || num <= 0
      return false 
    elsif num.round(2) != num
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
  
  def non_empty_array?(array_of_something)
    if array_of_something.class != Array 
      return false
    elsif array_of_something.length == 0
      return false
    end
    return true
  end
  
  
  ### COPIED FROM PREV HWK ASSIGNMENTS, DID NOT WRITE UNIT TESTS
  def checkCurrency(string_variable)
    # returns string_variable as a float
    # else returns false and error msg if string_variable can't be a number or a valid dollar amount 
    
    if checkNum?(string_variable) == false
      return false
    end
    
    # check for max 2 places past decimal point
    decimalIndex = string_variable.index('.')
    if decimalIndex != nil
      if string_variable.length - decimalIndex > 3
        puts "\t#{string_variable} is NOT a valid dollar amount"
        return false
      end
    end
    
    float_variable = string_variable.to_f
    if float_variable >= 0
      return float_variable
    else
      return false
    end
  end
  
  def checkNum?(string_variable)  
    # returns True if string_variable can be converted to a number, else False and prints error msg
    
    # reformat numbers ending in a decimal, such as 3. or 5. otherwise they will fail the following Float() check
    if string_variable[-1] == "."
      string_variable = string_variable[0...-1]
    end
    # will print error msg if unable to convert string_variable to a float  
    begin
      Float(string_variable) 
      return true
    rescue 
      puts "\t#{string_variable} is NOT a valid number"
      return false
    end
  end
  
  
end
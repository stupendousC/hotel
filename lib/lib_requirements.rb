require 'time'
require 'csv'
require_relative 'csv_record'

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

  
  
  # # NEED TO TEST THIS!!!
  
  def csv_back_to_array_of_ids(string)
    array = string_of_array_to_actual_array(string)
    result = array_of_str_to_array_of_int(array)
    return result
  end
  
  # helper for csv_back_to_array_of_ids
  def string_of_array_to_actual_array(string)
    array =[]
    garbage = [ '[', ']', ',']
    garbage.each do |char|
      string.delete!(char)
    end
    array = string.split
    return array
  end
  # helper for csv_back_to_array_of_ids
  def array_of_str_to_array_of_int(array)
    result = array.map do |str|
      str.to_i
    end
  end
end

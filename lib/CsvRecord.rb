require_relative 'lib_requirements.rb'

class CsvRecord
  # parent class of Room, Reservation, and Block
  attr_reader :id
  include Helpers
  
  def initialize(id)
    self.class.validate_id(id)
    @id = id
  end
  
  # Takes either full_path or directory and optional file_name
  # Default file name matches class name
  def self.load_all(full_path: nil, directory: nil, file_name: nil)
    full_path ||= build_path(directory, file_name)
    
    # takes file_name and turns each line into a new instance of that child (Passenger or Trip)
    # then returns an array of those Child instances
    return CSV.read(
      full_path,
      headers: true,
      header_converters: :symbol,
      converters: :numeric
    ).map { |record| from_csv(record) }
  end
  
  def self.validate_id(id)
    if id.nil? || id <= 0
      raise ArgumentError, 'ID cannot be blank or less than zero.'
    end
  end


  # B/c of the way I wrote data to CSV...
  # to load it back to useable form I'd need to translate it thusly
  def self.csv_back_to_array_of_ids(string)
    array = string_of_array_to_actual_array(string)
    result = array_of_str_to_array_of_int(array)
    return result
  end
  
  # helper for csv_back_to_array_of_ids
  def self.string_of_array_to_actual_array(string)
    array =[]
    garbage = [ '[', ']', ',']
    garbage.each do |char|
      string.delete!(char)
    end
    array = string.split
    return array
  end
  # helper for csv_back_to_array_of_ids
  def self.array_of_str_to_array_of_int(array)
    result = array.map do |str|
      str.to_i
    end
  end

  
  private
  
  def self.from_csv(record)
    # Not meant for CsvRecord use
    # only meant for <childClass>.csv to make more childClass instances
    raise NotImplementedError, 'Implement me in a child class!'
  end
  
  def self.build_path(directory, file_name)
    unless directory
      raise ArgumentError, "Either full_path or directory is required"
    end
    
    unless file_name
      # class_name would be taken from CsvRecord::Passenger or CsvRecord::Trip
      # and sets file_name to Passengers.csv or Trips.csv
      class_name = self.to_s.split('::').last
      file_name = "#{class_name.downcase}s.csv"
    end
    
    return "#{directory}/#{file_name}"
  end
end


### NOTE TO SELF ###
# PARSING MY OWN CSV
# if it looks like "", then it's an empty String
# if it looks like [], then it's a Str of "[]"
# if it looks like nil, then it's Nil
#######
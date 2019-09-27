require_relative 'lib_requirements.rb'
require_relative 'csvRecord.rb'

class Room < CsvRecord
  include Helpers
  attr_reader :id, :nightly_rate, :occupied_nights, :all_blocks_ids, :all_reservations_ids
  attr_accessor :all_reservations, :all_blocks
  # Format of @occupied_nights is SORTED, [ DateObj1, DateObj2, DateObj3, etc]
  
  # WHEN LOADING FROM CSV... hotelFrontDesk.new will invoke Room.load_all, which calls Room.from_csv, then calls Room.new()
  def self.load_all(full_path: nil, directory: nil, file_name: nil)
    super
  end
  
  def self.from_csv(record)
    # This will be called from hotelFrontDesk.rb, to pull info via .load_all()
    occupied_nights_strs = record[:occupied_nights_strs].split
    occupied_nights = occupied_nights_strs.map do |date_str|
      Date.parse(date_str)
    end
    
    return new(
      id: record[:id].to_i,
      nightly_rate: record[:nightly_rate].to_f,
      occupied_nights: occupied_nights, 
      all_reservations_ids: csv_back_to_array_of_ids(record[:all_reservations_ids]) , 
      all_blocks_ids: csv_back_to_array_of_ids(record[:all_blocks_ids])
    )
  end
  
  def initialize(id: , nightly_rate: STANDARD_RATE, occupied_nights: [], all_reservations: [], all_blocks_ids: [], all_reservations_ids: [])
    # validate id
    unless non_zero_integer?(id)
      raise ArgumentError, "id #{id} must be a non-zero integer"
    end
    @id = id
    
    # validate nightly_rate 
    if (nightly_rate != STANDARD_RATE) && !(non_zero_dollar_float?(nightly_rate))
      raise ArgumentError, "nightly_rate #{nightly_rate} must be a non-zero dollar Float"
    end
    @nightly_rate = nightly_rate
    
    @occupied_nights = occupied_nights
    @all_reservations = all_reservations
    @all_reservations_ids = all_reservations_ids
    @all_blocks = []
    @all_blocks_ids = all_blocks_ids
  end
  
  def change_rate(new_nightly_rate:)
    if non_zero_dollar_float? new_nightly_rate
      @nightly_rate = new_nightly_rate
      return true
    else
      raise ArgumentError, "new_nighty_rate must be a non-zero integer!"
    end
  end
  
  
  def check_avail?(date_range_obj)
    # checks all dates within the range and returns T/F
    start_date = date_range_obj.start_date
    end_date = date_range_obj.end_date
    curr_date = start_date
    
    while curr_date < end_date 
      # not checking end_date b/c won't stay that night anyway
      # refactor: use binary search since list is sorted?
      
      if @occupied_nights.include? curr_date
        return false
      else
        curr_date += 1
      end
    end
    # at this point the date range is available for this Room instance
    return true
  end
  
  def make_unavail(date_range_obj)
    # adds all the date objs (EXCEPT end-date b/c checkout @ noon) from the range to @occupied_nights
    # then sort @@occupied_nights
    unless date_range_obj.class == DateRange 
      raise ArgumentError, "requires a DateRange object"
    end
    
    start_date = date_range_obj.start_date
    end_date = date_range_obj.end_date
    curr_date = start_date
    while curr_date < end_date
      @occupied_nights << curr_date
      curr_date += 1
    end
    
    # @occupied_nights.sort!
  end
  
  def add_block_ids(block_obj)
    @all_blocks_ids << block_obj.id
  end
  
  def add_reservation(reservation_obj)
    if reservation_obj.class == Reservation 
      if reservation_obj.room_id == id
        @all_reservations << reservation_obj
      else
        raise ArgumentError, "Dafuq? That's a different room's reservation!"
      end
    else
      raise ArgumentError, "Non-Reservation obj shan't make it onto this here list"
    end
  end
  
  def to_s
    return "Room ##{id}"
  end
  
  
end
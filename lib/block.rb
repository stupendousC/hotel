require_relative 'lib_requirements'
require_relative 'csvRecord'

class Block < CsvRecord
  include Helpers
  attr_reader :id, :date_range, :new_nightly_rate, :occupied_room_ids, :unoccupied_room_ids, :all_reservations_ids
  attr_accessor :occupied_rooms, :unoccupied_rooms, :all_reservations
  
  # WHEN LOADING FROM CSV... hotelFrontDesk.new will invoke Block.load_all, which calls Block.from_csv, then calls Block.new()
  def self.load_all(full_path: nil, directory: nil, file_name: nil)
    super
  end
  
  def self.from_csv(record)
    # This will be called from hotelFrontDesk.rb, to pull info via .load_all()
    start_date = Date.parse(record[:start_date])
    end_date = Date.parse(record[:end_date])
    range = DateRange.new(start_date_obj:start_date, end_date_obj:end_date)
    
    return new(
      from_csv: true,
      id: record[:id].to_i,
      date_range: range,
      new_nightly_rate: record[:new_nightly_rate].to_f,
      occupied_room_ids: csv_back_to_array_of_ids(record[:occupied_room_ids]),
      unoccupied_room_ids: csv_back_to_array_of_ids(record[:unoccupied_room_ids]),
      all_reservations_ids: csv_back_to_array_of_ids(record[:all_reservations_ids])
    )
  end
  
  def initialize(id: nil, date_range:, new_nightly_rate: nil, room_ids:nil, rooms:nil, occupied_room_ids:nil, unoccupied_room_ids: nil, all_reservations_ids:nil, from_csv:nil) 
    # If making a new instance via hotelFrontDesk: all arg validations done by precursor method HotelFrontDesk#make_block
    # If downloading from CSV, then assuming that they've already been vetted
    
    @date_range = date_range
    (@new_nightly_rate = new_nightly_rate) if new_nightly_rate
    
    if from_csv
      id ? (@id = id):(raise ArgumentError, "Must have already been assigned an id!")
      occupied_room_ids ? (@occupied_room_ids = occupied_room_ids):(@occupied_room_ids = [])
      unoccupied_room_ids ? (@unoccupied_room_ids = unoccupied_room_ids):(@unoccupied_room_ids = [])
      all_reservations_ids ? (@all_reservations_ids = all_reservations_ids):(@all_reservations_ids = [])
    else
      # making new instance from scratch
      @id = Block.generate_id
      @occupied_rooms = []
      @occupied_room_ids = []
      @unoccupied_rooms = rooms
      @unoccupied_room_ids = room_ids
      @all_reservations = []
      @all_reservations_ids = []
    end
  end
  
  def to_s
    return "Block ##{id}"
  end
  
  class << self
    @@available_id = 2000
    
    def generate_id
      @@available_id += 1
      return @@available_id
    end
  end
  
end
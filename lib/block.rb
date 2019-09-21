require_relative 'lib_requirements.rb'

class Block
  include Helpers
  attr_reader :id, :date_range, :new_nightly_rate, :occupied_rooms, :occupied_room_ids, :unoccupied_rooms, :unoccupied_room_ids, :all_reservations
  
  def initialize(date_range:, new_nightly_rate:, room_ids:, rooms:)
    # Arg validation is handled by HotelFrontDesk, new Block is initialized only if passed tests
    
    @id = Block.generate_id
    @date_range = date_range
    @new_nightly_rate = new_nightly_rate
    @occupied_rooms = []
    @occupied_room_ids = []
    @unoccupied_rooms = rooms
    @unoccupied_room_ids = room_ids
    @all_reservations = []
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
require_relative 'lib_requirements.rb'
require_relative 'room'
# require_relative 'WHATEVER'

class Hotel_front_desk
  include Helpers
  attr_reader :all_rooms, :all_reservations, :num_rooms_in_hotel

  def initialize (num_rooms_in_hotel: 20, all_rooms: [], all_reservations: [])
    @all_rooms = all_rooms
    @all_reservations = all_reservations

    # set up Room instances
    @num_rooms_in_hotel = num_rooms_in_hotel
    @num_rooms_in_hotel.times do |i|
      room = Room.new(id: (i+1))
      @all_rooms << room
    end
  end

  def list_all_rooms
    list = "LIST OF ALL ROOMS:\n"
    @all_rooms.each { |room| list << "  ROOM ##{room.id}\n" }
    return list
  end

  def make_reservation(*arg)
  end

  def calc_cost(*arg)
  end

  def list_reservation(date)
  end

  def to_s
    return "Room ##{self.id}"
  end
end
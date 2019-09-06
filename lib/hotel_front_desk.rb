require_relative 'lib_requirements.rb'
require_relative 'room'
require_relative 'reservation'
require_relative 'date_range'

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

  def make_reservation(date_range:, customer:)
    # args validation: no need for customer except just a non-empty string for now
    if date_range.class != Date_range
      raise ArgumentError, "Requires a Date_range object"
    elsif  (customer == "") 
      raise ArgumentError, "Customer must have a name..."
    elsif (customer.class != String)
      raise ArgumentError, "We don't take kindly to non-String customers around here!"
    end

    # go thru @all_rooms, result is either a room or nil
    room = find_avail_room(date_range)
    return nil if room == nil

    # update Room w/ make_unavail, add to Room.reservations

    # update @all_reservations
  end

  def find_avail_room(date_range)
    # returns Room object that is unoccupied on date_range, or nil if no rooms
    @all_rooms.each do |room|
      return room if room.check_avail?(date_range)
    end
    return nil
  end


  def calc_cost(*arg)
    # I think i'm going to make reservatin do calc_cost
  end

  def list_reservation(date)
    # go thru @all_reservations
    # compare date to each one's start-date & end_date, add to results[] if inclusive
  end

end
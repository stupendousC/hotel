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
  
  def make_reservation(date_range:, customer:, new_nightly_rate: nil)
    if date_range.class != Date_range
      raise ArgumentError, "Requires a Date_range object"
      
      
    elsif  (customer == "") || (customer == nil)
      raise ArgumentError, "Customer must have a name..."
    elsif (customer.class != String)
      raise ArgumentError, "We don't take kindly to non-String customers around here!"
      
    elsif new_nightly_rate
      if new_nightly_rate.class != Integer
        raise ArgumentError, "New_nightly_rate must be an Integer"
      elsif !(non_zero_integer? new_nightly_rate)
        raise ArgumentError, "New_nightly_rate must be a non-zero Integer"
      end
      # I chose to allow new_nightly_rate to be higher number than standard rate
    end
    
    # go thru @all_rooms, result is either a room or nil
    room = find_avail_room(date_range)
    if room == nil
      return nil
    end
    
    # By now, all args have passed validation tests
    reservation = Reservation.new(room_id: room.id, room: room, date_range: date_range, customer: customer, new_nightly_rate: new_nightly_rate)
    
    # update Room w/ make_unavail, add to Room.reservations
    room.make_unavail(date_range)
    room.all_reservations << reservation
    
    # update @all_reservations
    @all_reservations << reservation
    
    return reservation
  end
  
  def find_avail_room(date_range)
    # returns Room object that is unoccupied on date_range, or nil if no rooms
    @all_rooms.each do |room|
      return room if room.check_avail?(date_range)
    end
    return nil
  end
  
  
  def get_cost(reservation_id)
    reservation = @all_reservations.find { |res| res.id == reservation_id }

    if reservation == nil
      raise ArgumentError, "No reservations with id##{reservation_id} exists"
    end
    return reservation.cost
  end
  
  def list_reservation(date)
    if date.class != Date
      raise ArgumentError, "You must pass in a Date object"
    end

    # go thru @all_reservations
    results = @all_reservations.find_all { |reservation| 
      reservation.date_range.date_in_range? (date)
    }

    

    if results == []
      puts "\nNO RESERVATIONS FOR DATE #{date}"
      return nil
    else
      puts "\nLISTING RESERVATIONS FOR DATE #{date}..."
      results.each { |e| puts e}
      return results
    end
  end
  
end
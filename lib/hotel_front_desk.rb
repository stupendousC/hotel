require_relative 'lib_requirements.rb'
require_relative 'room'
require_relative 'reservation'
require_relative 'date_range'

class Hotel_front_desk
  include Helpers
  attr_reader :all_rooms, :all_reservations, :all_blocks, :num_rooms_in_hotel
  
  def initialize (num_rooms_in_hotel: 20, all_rooms: [], all_reservations: [], all_blocks: [])
    @all_rooms = all_rooms
    @all_reservations = all_reservations
    @all_blocks = all_blocks

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
    if !room 
      raise ArgumentError, "No rooms at this inn"
      # I'd prefer to return nil but the rubric calls for raising errors
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
    # returns 1 Room object that is unoccupied on date_range, or nil if no rooms
    @all_rooms.each do |room|
      return room if room.check_avail?(date_range)
    end
    return nil
  end
  
  def find_all_avail_rooms(date_range)
    # returns all Room objects that are unoccupied on date_range, or nil if no rooms
    if date_range.class != Date_range
      raise ArgumentError, "You must pass in a Date_range object"
    end    
    return @all_rooms.find_all { |room| room.check_avail?(date_range)} 
  end
  
  def get_cost(reservation_id)
    reservation = @all_reservations.find { |res| res.id == reservation_id }
    
    if reservation == nil
      raise ArgumentError, "No reservations with id##{reservation_id} exists"
    end
    return reservation.cost
  end
  
  def list_reservations(date)
    if date.class != Date
      raise ArgumentError, "You must pass in a Date object"
    end
    
    # go thru @all_reservations
    results = @all_reservations.find_all { |reservation| 
    reservation.date_range.date_in_range? (date) }
    
    if results == []
      string = "\nNO RESERVATIONS FOR DATE #{date}" 
    else
      string = "\nLISTING RESERVATIONS FOR DATE #{date}..."
      results.each { |reservation| string << "\n  #{reservation}" }
    end
    return string
  end
  
  def list_available_rooms(date_range)
    results = find_all_avail_rooms(date_range)
    if results == []
      string = "\nNO ROOMS AVAILABLE FOR #{date_range.start_date} TO #{date_range.end_date}"
    else
      string = "\nLISTING AVAILABLE ROOMS FOR #{date_range.start_date} TO #{date_range.end_date}..."
      results.each { |room| string << "\n  #{room}"}
    end
    return string
  end
  
  def get_room_from_id(id_arg)
    if id_arg.class != Integer
      raise ArgumentError, "Room id# should be an integer..."
    end
    
    room = @all_rooms.find { |room| room.id == id_arg }
    
    if room
      return room
    else
      raise ArgumentError, "Room ##{id_arg} does not exist"
    end
  end
  
  def get_rooms_from_ids (room_ids)
    # given room_ids in an array, return an array of Room instances
    
    if room_ids.length > num_rooms_in_hotel
      raise ArgumentError, "You're asking for more rooms than in existence at this here hotel"
    elsif room_ids.uniq.length != room_ids.length
      raise ArgumentError, "Some of your args are duplicates, fix it plz"
    end
    
    rooms = []
    (room_ids).each do |id|
      room = get_room_from_id(id)
      rooms << room
    end
    return rooms
  end
  
  def make_block(date_range:, room_ids:, new_nightly_rate:)
    # Validate date_range
    if date_range.class != Date_range
      raise ArgumentError, "Must pass in a Date_range object"
    else
      @date_range = date_range
    end
    
    # Validate room_ids[]
    if room_ids.class != Array
      raise ArgumentError, "Require room_ids to be in an array"
    elsif room_ids.length == 0
      raise ArgumentError, "You didn't put anything in room_ids"
    elsif room_ids.length > MAX_BLOCK_SIZE
      raise ArgumentError, "Max block size allowed is #{MAX_BLOCK_SIZE}"
    else
      @room_ids = room_ids
      # continue validating as we check rooms' availability later 
    end
    
    # Validate new_nightly_rate
    if !non_zero_integer?(new_nightly_rate)
      raise ArgumentError, "We need a non-zero Integer for new_nightly_rate"
    elsif new_nightly_rate >= STANDARD_RATE
      raise ArgumentError, "Shouldn't the new_nightly_rate be a discount? compared to standard rate of #{STANDARD_RATE}?"
    else
      @new_nightly_rate = new_nightly_rate
    end
    
    # Checking rooms' actual availability
    rooms_ready_for_block = []
    rooms = get_rooms_from_ids(room_ids)
    
    rooms.each do |room|
      room.occupied_nights.each do |occupied_night|
        if date_range.date_in_range?(occupied_night)
          unless occupied_night == date_range.end_date
            # Not a real clash b/c one has checkin vs the other has checkout
            raise ArgumentError, "Can't block Room ##{room.id} b/c it's occupied on #{occupied_night}"
          end
        end
      end
      
      # room is available for block's date range
      rooms_ready_for_block << room
    end
    
    # Update Room objects's occupied_nights so no one else can take it
    rooms_ready_for_block.each do |room|
      room.make_unavail(date_range)
    end
    
    # Make block & update @all_blocks
    block = Block.new(date_range: date_range, new_nightly_rate: new_nightly_rate, room_ids: room_ids, rooms: rooms_ready_for_block)
    @all_blocks << block
    return block
  end
  
  def make_reservation_from_block(room_id:, customer:)
    unless non_zero_integer? room_id
      raise ArgumentError, "We need a non-zero Integer for the room_id"
    end

    if customer == "" or !customer
      raise ArgumentError, "We need a customer name!"
    elsif customer.class != String
      raise ArgumentError, "Customer name needs to be a String"
    end
    
    # Does a block exist containing this room_id?
    block_exists = false
    block = nil
    room = nil
    all_blocks.each do |blk|
      if blk.occupied_room_ids.include? room_id
        raise ArgumentError, "Room ##{room_id} is already taken"
      elsif blk.unoccupied_room_ids.include? room_id
        block = blk
        room = get_room_from_id(room_id)
        block_exists = true
      end
    end

    # no need to update Room obj's occupied_nights, they're already marked when Block was created

    # Make Reservation object, then update attribs for Block obj, Room obj, and Hotel obj 
    if block_exists
      block.occupied_rooms << room
      block.occupied_room_ids << room_id
      block.unoccupied_room_ids.delete(room_id) 
      block.unoccupied_rooms.delete(room)
      new_res = Reservation.new(room_id: room_id, room:room, date_range:block.date_range, customer: customer, new_nightly_rate: block.new_nightly_rate, block: block)
      room.all_reservations << new_res
      @all_reservations << new_res
    else
      raise ArgumentError, "Room ##{room_id} is not in a Block, plz use regular .make_reservation()"
    end

    return new_res
  end
  
end
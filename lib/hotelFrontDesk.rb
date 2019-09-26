require_relative 'lib_requirements.rb'
require_relative 'room'
require_relative 'reservation'
require_relative 'block'
require_relative 'dateRange'
require_relative 'csvRecord'

class HotelFrontDesk
  include Helpers
  attr_reader :all_rooms, :all_reservations, :all_blocks, :num_rooms_in_hotel
  # attr_accessor :all_rooms, :all_reservations, :all_blocks, :num_rooms_in_hotel
  
  def initialize (num_rooms_in_hotel: 20, all_rooms: [], all_reservations: [], all_blocks: [], use_csv: false)
    if use_csv
      # Loading data from CSV & initiating objs using that
      @all_rooms = Room.load_all(full_path: ALL_ROOMS_CSV)
      @all_reservations = Reservation.load_all(full_path: ALL_RESERVATIONS_CSV)
      @all_blocks = Block.load_all(full_path: ALL_BLOCKS_CSV)
      
      # B/c CSV can't store objects, will need to reconnect obj attribs for all Room/Reservation/Block instances
      # For Reservation objs in @all_reservations, will need to add their own @block and @room
      @all_reservations.each do |res_obj|
        res_obj.room = get_room_from_id(res_obj.room_id)
        if res_obj.block_id
          res_obj.block = get_block_from_id(res_obj.block_id)
        end
      end
      
      # For Block objs in @all_blocks, will need to add their own @occupied_rooms, @unoccupied_rooms, and @all_reservations
      @all_blocks.each do |block_obj|
        if block_obj.occupied_room_ids != []
          block_obj.occupied_rooms = get_rooms_from_ids(block_obj.occupied_room_ids)
        end
        if block_obj.unoccupied_room_ids != []
          block_obj.unoccupied_rooms = get_rooms_from_ids(block_obj.unoccupied_room_ids)
        end
        if block_obj.all_reservations_ids != []
          block_obj.all_reservations = get_reservations_from_ids(block_obj.all_reservations_ids)
        end
      end
      
      # For Room objs in @all_rooms, will need to add their own @all_reservations and @all_blocks
      @all_rooms.each do |room_obj|
        if room_obj.all_reservations_ids != []
          room_obj.all_reservations = get_reservations_from_ids(room_obj.all_reservations_ids)
        end
        if room_obj.all_blocks_ids != []
          room_obj.all_blocks = get_blocks_from_ids(room_obj.all_blocks_ids)
        end
      end
      
    else
      # Making all new objects
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
  end
  
  def write_csv(all_rooms_target:, all_blocks_target:, all_reservations_target:)
    # RESERVATIONS
    CSV.open(all_reservations_target, "w") do |file|
      file << ["id", "room_id", "cost", "customer", "start_date", "end_date", "new_nightly_rate", "block_id"]
      all_reservations.each do |res|
        puts "SAVING #{res}..."
        file << [res.id, res.room_id, res.cost, res.customer, res.start_date, res.end_date, res.new_nightly_rate, res.block_id]
      end
    end
    
    # BLOCKS
    CSV.open(all_blocks_target, "w") do |file|
      file << ["id", "start_date", "end_date", "new_nightly_rate", "occupied_room_ids", "unoccupied_room_ids", "all_reservations_ids"]
      
      all_blocks.each do |block|
        puts "SAVING #{block}..."
        file << [block.id, block.date_range.start_date, block.date_range.end_date, block.new_nightly_rate, block.occupied_room_ids, block.unoccupied_room_ids, block.all_reservations_ids]
      end
    end
    
    # ROOMS
    CSV.open(all_rooms_target, "w") do |file|
      file << ["id", "nightly_rate", "occupied_nights_strs", "all_reservations_ids", "all_blocks_ids"]
      all_rooms.each do |room|
        puts "SAVING #{room}..."
        occupied_nights_strs = ""
        room.occupied_nights.each do |date_obj| 
          occupied_nights_strs << date_obj.to_s 
          occupied_nights_strs << " "
        end
        file << [room.id, room.nightly_rate, occupied_nights_strs, room.all_reservations_ids, room.all_blocks_ids]
      end
    end
  end
  
  def list_all_rooms
    list = "LIST OF ALL ROOMS:\n"
    @all_rooms.each { |room| list << "  ROOM ##{room.id}\n" }
    return list
  end
  
  def find_avail_room(date_range)
    # returns 1 Room object that is unoccupied on date_range, or nil if no rooms
    if date_range.class != DateRange
      raise ArgumentError, "You must pass in a DateRange object"
    end    
    return @all_rooms.find { |room| room.check_avail?(date_range)} 
  end
  
  def find_all_avail_rooms(date_range)
    # returns all Room objects that are unoccupied on date_range, or nil if no rooms
    if date_range.class != DateRange
      raise ArgumentError, "You must pass in a DateRange object"
    end    
    return @all_rooms.find_all { |room| room.check_avail?(date_range)} 
  end
  
  def make_reservation(date_range:, customer:, new_nightly_rate: nil)
    # currently does not allow u to choose specific room.  FUture improvement!
    if date_range.class != DateRange
      raise ArgumentError, "Requires a DateRange object"
      
    elsif !non_blank_string? customer
      raise ArgumentError, "Customer must have a name string!"
      
    elsif new_nightly_rate
      if !(non_zero_dollar_float? new_nightly_rate)
        raise ArgumentError, "New_nightly_rate must be a non-zero dollar float"
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
    room.all_reservations_ids << reservation.id
    
    # update @all_reservations
    @all_reservations << reservation
    
    return reservation
  end
  
  def get_cost(reservation_id)
    if reservation_id.class == Integer
      reservation = @all_reservations.find { |res| res.id == reservation_id }
    else
      raise ArgumentError, "Reservation id needs to be an Integer"
    end
    
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
    results = @all_reservations.find_all { |reservation| reservation.date_range.date_in_range? (date) }
    
    if results == []
      string = "\nNO RESERVATIONS FOR DATE #{date}" 
    else
      string = "\nLISTING RESERVATIONS FOR DATE #{date}..."
      results.each { |reservation| string << "\n  #{reservation}" }
    end
    return string
  end
  
  def list_available_rooms(date_range)
    # arg validation done in find_all_avail_rooms
    results = find_all_avail_rooms(date_range)
    if results == []
      string = "\nNO ROOMS AVAILABLE FOR #{date_range.start_date} TO #{date_range.end_date}"
    else
      string = "\nLISTING AVAILABLE ROOMS FOR #{date_range.start_date} TO #{date_range.end_date}..."
      results.each { |room| string << "\n  #{room}"}
    end
    return string
  end
  
  def get_room_from_id(id_int)
    if id_int.class != Integer
      raise ArgumentError, "Room id# should be an integer..."
    end
    
    room = @all_rooms.find { |room| room.id == id_int }
    
    if room
      return room
    else
      raise ArgumentError, "Room ##{id_int} does not exist"
    end
  end
  
  def get_rooms_from_ids (room_ids)
    # given room_ids in an array, return an array of Room instances
    
    if !non_empty_array? room_ids
      raise ArgumentError, "Expecting argument of room_ids in an Array"
      # room_id.class == Integer will be checked in get_room_from_id later
    elsif num_rooms_in_hotel && (room_ids.length > num_rooms_in_hotel)
      raise ArgumentError, "You're asking for more rooms than in existence at this here hotel"
    elsif room_ids.uniq.length != room_ids.length
      raise ArgumentError, "Some of your args are duplicates, fix it plz"
    end
    
    rooms = room_ids.map { |id| get_room_from_id(id) }
    return rooms
  end
  
  def get_block_from_id(id_int)
    if id_int.class != Integer
      raise ArgumentError, "Block id# should be an integer..."
    end
    
    block = @all_blocks.find { |block| block.id == id_int }
    
    if block
      return block
    else
      raise ArgumentError, "Block ##{id_int} does not exist"
    end
  end
  
  def get_blocks_from_ids(block_ids)
    # given block_ids in an array, return an array of Block instances
    if !non_empty_array? block_ids
      raise ArgumentError, "Expecting argument of block_ids in an Array"
    elsif block_ids.uniq.length != block_ids.length
      raise ArgumentError, "Some of your args are duplicates, fix it plz"
    end
    
    blocks = block_ids.map { |block_id| get_block_from_id(block_id) }
    return blocks
  end
  
  def get_reservation_from_id(id_int)
    if id_int.class != Integer
      raise ArgumentError, "Reservation id# should be an integer..."
    end
    
    res = @all_reservations.find { |res| res.id == id_int }
    
    if res
      return res
    else
      raise ArgumentError, "Reservation ##{id_int} does not exist"
    end
  end
  
  def get_reservations_from_ids(res_ids)
    # given res_ids in an array, return an array of Reservation instances
    if !non_empty_array? res_ids
      raise ArgumentError, "Expecting argument of res_ids in an Array"
    elsif res_ids.uniq.length != res_ids.length
      raise ArgumentError, "Some of your args are duplicates, fix it plz"
    end
    
    reservations = res_ids.map { |res_id| get_reservation_from_id(res_id) }
    return reservations
  end
  
  def make_block(date_range:, room_ids:, new_nightly_rate:)
    # Validate date_range
    if date_range.class != DateRange
      raise ArgumentError, "Must pass in a DateRange object"
    else
      @date_range = date_range
    end
    
    # Validate room_ids[]
    if !non_empty_array? room_ids
      raise ArgumentError, "Expecting argument of room_ids in an Array"
    elsif room_ids.length > MAX_BLOCK_SIZE
      raise ArgumentError, "Max block size allowed is #{MAX_BLOCK_SIZE}"
    else
      @room_ids = room_ids
      # continue validating as we check rooms' availability later 
    end
    
    # Validate new_nightly_rate
    if !non_zero_dollar_float?(new_nightly_rate)
      raise ArgumentError, "We need a non-zero dollar Float for new_nightly_rate"
    elsif new_nightly_rate >= STANDARD_RATE
      raise ArgumentError, "Shouldn't the new_nightly_rate be a discount? compared to standard rate of #{STANDARD_RATE}?"
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
    
    # Make block & update @all_blocks
    block = Block.new(date_range: date_range, new_nightly_rate: new_nightly_rate, room_ids: room_ids, rooms: rooms_ready_for_block)
    @all_blocks << block
    
    # Update Room objects's occupied_nights so no one else can take it
    rooms_ready_for_block.each do |room|
      room.make_unavail(date_range)
      room.add_block_ids(block)
    end
    
    return block
  end
  
  def make_reservation_from_block(room_id:, customer:)
    if !non_zero_integer? room_id
      raise ArgumentError, "We need a non-zero Integer for the room_id"
    elsif !non_blank_string? customer
      raise ArgumentError, "Customer must have a name string!"
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
        break
      end
    end
    
    # no need to update Room obj's occupied_nights, they're already marked when Block was created
    
    # Make Reservation object, then update attribs for Block obj, Room obj, and Hotel obj 
    if block_exists
      new_res = Reservation.new(room_id: room_id, room:room, date_range:block.date_range, customer: customer, new_nightly_rate: block.new_nightly_rate, block: block, block_id: block.id)
      
      block.occupied_rooms << room
      block.occupied_room_ids << room_id
      block.unoccupied_room_ids.delete(room_id) 
      block.unoccupied_rooms.delete(room)
      room.all_reservations << new_res
      room.all_reservations_ids << new_res.id
      @all_reservations << new_res
      block.all_reservations << new_res
      block.all_reservations_ids << new_res.id
    else
      raise ArgumentError, "Room ##{room_id} is not in a Block, plz use regular .make_reservation()"
    end
    
    return new_res
  end
  
  def list_available_rooms_from_block(block_id)
    block = get_block_from_id(block_id)
    
    if block.unoccupied_room_ids != []
      string = "\nLISTING AVAILABLE ROOMS FOR BLOCK #{block_id}..."
      block.unoccupied_room_ids.each { |room_id| string << "\n  Room ##{room_id}"}
    else
      string = "\nNO ROOMS AVAILABLE FOR BLOCK #{block_id}"
    end
    
    return string
  end
  
  def change_room_rate(room_id:, new_nightly_rate:)
    room_obj = get_room_from_id(room_id)
    if non_zero_dollar_float? new_nightly_rate
      room_obj.change_rate(new_nightly_rate: new_nightly_rate)
    else
      raise ArgumentError, "new_nightly_rate must be a non-zero integer"
    end
  end
  
  
  ### EVERYTHING BELOW THIS LINE IS FOR THE COMMAND-LINE INTERFACE IN MAIN.RB ###
  ### NO VALIDATION OR UNIT TESTS WRITTEN due to time ###
  def hash_of_all_methods
    return { A: "List all rooms", 
      B: "List available rooms",
      C: "Make reservation",
      D: "List reservations",
      E: "Get cost",
      F: "Make block",
      G: "Make reservation from block",
      H: "List available rooms from block",
      I: "Change room rate", 
      Q: "Quit" 
    }
  end
  
  def show_menu
    puts "MAIN MENU:"
    hash_of_all_methods.each do |key, value|
      puts "  #{key}: #{value}"
    end
  end
  
  def prompt_for_input(statement: "PLEASE MAKE A SELECTION")
    puts statement
    print ">>> " 
    choice = gets.chomp
    return choice.upcase
  end
  
  def prompt_for_date
    date = prompt_for_input(statement: "Please provide the date, as YYYY-MM-DD")
    return Date.parse(date)
  end
  
  def prompt_for_date_range
    start_date = prompt_for_input(statement: "Please provide the start date, as YYYY-MM-DD")
    end_date = prompt_for_input(statement: "Please provide the end date, as YYYY-MM-DD")
    start_date = Date.parse(start_date)
    end_date = Date.parse(end_date)
    date_range = DateRange.new(start_date_obj: start_date, end_date_obj: end_date)
    return date_range
  end
  
  def prompt_for_new_nightly_rate
    new_nightly_rate = prompt_for_input(statement: "Is there a new nightly rate? Else press enter")
    if new_nightly_rate == "" 
      return nil
    else 
      float_or_nil = checkCurrency(new_nightly_rate)
      if float_or_nil
        return float_or_nil
      else
        raise ArgumentError, "Not a valid dollar float?  Investigate!"
      end
    end
  end
  
  def prompt_for_array_of_ids
    result = []
    statement = "Please enter the id number, or Q to quit"
    quitting_time = false
    until quitting_time
      id = (prompt_for_input(statement: statement)).to_i
      if non_zero_integer? id
        result << id
      elsif id == "Q"
        return result
      else
        # raise error?
        puts "Nope! Invalid entry!"
        return result
      end
    end
  end
  
end

require "./lib/hotelFrontDesk.rb"

###
# DUE TO TIME LIMITATIONS, NO VALIDATIONS OR UNIT TESTS ARE WRITTEN FOR CSV WRITING/LOADING AND EVERYTHING ELSE IN THIS COMMAND-LINE INTERFACE!
# ALL OTHER CODE IN THE INDIVIDUAL CLASSES ARE ALL TESTED WITH 100% COVERAGE THOUGH.

# NOTE TO FUTURE SELF:
# PROBLEM: If crashes, then all data during session is lost.  Should save all data as soon as they're made .  Future fix!
###
puts "\n\n#####################################################################"
puts "HEY THERE, I'M NOT 100% DONE YET, IT PAINS ME BUT I JUST DIDN'T HAVE ENOUGH TIME FOR EVERYTHING."
puts "I KNOW I CAN MAKE IT WITH UNIT TESTS AND THE WHOLE PROPER TREATMENT, I'M JUST CHOOSING TO USE MY TIME ON MORE IMPORTANT STUFF"
puts "#####################################################################\n\n"

##################### HELPER METHODS #####################
def print_error_msg(exception)
  puts "ERROR: #{exception.message}"
end 

def usd(float_var)
  return format("$%.2f", float_var)
end
##################### HELPER METHODS #####################




##################### BEGIN ACTUAL PROGRAM #####################
puts "WELCOME TO CAROLINE'S HOTEL APP!\n\n"

puts "Please choose from the following:"
puts "A. Load from previously saved CSV files"
puts "B. Start over with brand new data"
print "CHOICE >>> "
choice = gets.chomp

if choice.upcase == "A"
  hotel = HotelFrontDesk.new(use_csv:true)
elsif choice.upcase == "B"
  hotel = HotelFrontDesk.new()
  # seed_data
else
  puts "That's nonsense, we're quitting"
  exit()
end

# Here's where I would print hotel attribs to make sure CSV loaded properly

stay_in_loop = true
while stay_in_loop
  hotel.show_menu
  choice = hotel.prompt_for_input
  
  case choice
  when "A"
    puts "LISTING ALL ROOMS"
    puts hotel.list_all_rooms
    
  when "B"
    puts "LISTING ALL AVAILABLE ROOMS FOR DATE RANGE"
    begin
      date_range = hotel.prompt_for_date_range
      puts hotel.list_available_rooms(date_range)
    rescue => exception
      print_error_msg(exception)
    end
    
  when "C"
    puts "MAKING A RESERVATION"
    begin
      date_range = hotel.prompt_for_date_range
      customer = hotel.prompt_for_input(statement: "What's the customer's name?")
      new_nightly_rate = hotel.prompt_for_new_nightly_rate
      new_res = hotel.make_reservation(date_range:date_range, customer: customer, new_nightly_rate: new_nightly_rate)
      puts "CONFIRM: #{new_res}"
    rescue => exception
      print_error_msg(exception)
    end
    
  when "D"
    puts "LISTING ALL RESERVATIONS FOR A DATE"
    begin
      date = hotel.prompt_for_date
      puts hotel.list_reservations(date)
    rescue => exception
      print_error_msg(exception)
    end
    
  when "E"
    puts "Getting cost"
    begin
      res_id = hotel.prompt_for_reservation_id
      puts "Total is #{usd(hotel.get_cost(res_id))}"
    rescue => exception
      print_error_msg(exception)
    end
    
  when "F"
    puts "MAKING A BLOCK"
    begin
      date_range = hotel.prompt_for_date_range
      puts hotel.list_available_rooms(date_range)
      puts "Which rooms would you like for the block?"
      room_ids = hotel.prompt_for_array_of_ids
      new_nightly_rate = hotel.prompt_for_new_nightly_rate
      new_block = hotel.make_block(date_range:date_range, room_ids:room_ids, new_nightly_rate:new_nightly_rate)
      puts "CONFIRM: #{new_block}"
    rescue => exception
      print_error_msg(exception)
    end
    
    
  when "G"
    puts "MAKING A RESERVATION FROM BLOCK"
    begin
      block_id = hotel.prompt_for_block_id
      puts hotel.list_available_rooms_from_block(block_id)
      
      room_id = hotel.prompt_for_room_id
      customer = hotel.prompt_for_input(statement: "What's the customer's name?")
      new_res = hotel.make_reservation_from_block(room_id:room_id, block_id: block_id, customer:customer)
      puts "CONFIRM: #{new_res}"
    rescue => exception
      print_error_msg(exception)
    end
    
    
  when "H"
    puts "LIST AVAILABLE ROOMS FROM BLOCK"
    begin
      block_id = hotel.prompt_for_id(statement: "What is the block id?")
      puts hotel.list_available_rooms_from_block(block_id)
    rescue => exception
      print_error_msg(exception)
    end
    
    
  when "I"
    puts "CHANGE ROOM RATE"
    begin
      room_id = (hotel.prompt_for_input(statement: "What is the room id?")).to_i
      new_nightly_rate = hotel.prompt_for_new_nightly_rate
      hotel.change_room_rate(room_id:room_id, new_nightly_rate:new_nightly_rate)
      room = hotel.get_room_from_id(room_id)
      puts "CONFIRMING: Room ##{room_id}'s new rate is now #{usd(room.nightly_rate)}"
    rescue => exception
      print_error_msg(exception)
    end
    
    
  when "Q"
    print "\nLOGGING OFF, DO YOU WANT TO SAVE? >>> "
    choice = gets.chomp
    if choice == ""
      puts "Sounds like a no, ok we're leaving"
    elsif choice[0].upcase == "Y"
      puts "Ok, writing over all previously saved data with data from this session"
      hotel.write_csv(all_rooms_target:ALL_ROOMS_CSV, all_blocks_target:ALL_BLOCKS_CSV, all_reservations_target:ALL_RESERVATIONS_CSV)
    elsif choice[0].upcase == "N"
      puts "Ok, not saving"
    else 
      puts "That's nonsense, we're quitting anyway"
    end
    stay_in_loop = false
    
  else
    puts "INVALID CHOICE!"
  end
end
puts



########################### FOR MY OWN TESTING PURPOSES ############################
def seed_data
  # for my own testing purposes
  puts "Providing some seed data here"
  today = Date.today
  range1 = DateRange.new(start_date_obj: today, end_date_obj: today + 3)
  hotel.make_reservation(date_range: range1, customer: "Butters", new_nightly_rate: 50)
  hotel.make_reservation(date_range: range1, customer: "Me")
  hotel.make_block(date_range: range1, room_ids:[11,12,13,14,15], new_nightly_rate:100)
  hotel.make_reservation_from_block(room_id:11, customer:"Oski")
  hotel.make_reservation_from_block(room_id:12, customer: "Jesse")
  hotel.make_block(date_range: range1, room_ids:[19,20], new_nightly_rate:125)
end

# ######## test if CSV actually downloaded
# puts "\nSHOWING hotel.all_reservations..."
# puts hotel.all_reservations

# puts "\nSHOWING hotel.all_blocks..."
# puts hotel.all_blocks

# puts "\nSHOWING hotel.all_rooms..."
# puts hotel.all_rooms
########
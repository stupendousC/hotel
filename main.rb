require "./lib/hotelFrontDesk.rb"

###
# DUE TO TIME LIMITATIONS, NO VALIDATIONS OR UNIT TESTS ARE WRITTEN FOR CSV WRITING/LOADING AND EVERYTHING ELSE IN THIS COMMAND-LINE INTERFACE!
# ALL OTHER CODE IN THE INDIVIDUAL CLASSES ARE ALL TESTED WITH 100% COVERAGE THOUGH.

# NOTE TO FUTURE SELF:
# PROBLEM: If crashes, then all data during session is lost.  Should save all data as soon as they're made .  Future fix!
# Also put in rescue exceptions so it routes back to main loop, instead of getting kicked out of program
###
puts "\n\n#####################################################################"
puts "HEY THERE, I'M NOT 100% DONE YET, IT PAINS ME BUT I JUST DIDN'T HAVE ENOUGH TIME FOR EVERYTHING."
puts "NOMINAL CASES SHOULD WORK FINE, BUT B/C NO TIME TO RESCUE ANY ERRORS, YOU WILL GET KICKED OUT OF THE PROGRAM IF U GIVE ME WACKY ARGUMENTS"
puts "I KNOW I CAN MAKE IT WORK, WITH UNIT TESTS AND THE WHOLE PROPER TREATMENT, I'M JUST CHOOSING TO USE MY TIME ON MORE IMPORTANT STUFF"
puts "#####################################################################\n\n"

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
  puts "... we're providing some seed data here too"
  today = Date.today
  range1 = DateRange.new(start_date_obj: today, end_date_obj: today + 3)
  hotel.make_reservation(date_range: range1, customer: "Butters", new_nightly_rate: 50)
  hotel.make_reservation(date_range: range1, customer: "Me")
  hotel.make_block(date_range: range1, room_ids:[11,12,13,14,15], new_nightly_rate:100)
  hotel.make_reservation_from_block(room_id:11, customer:"Oski")
  hotel.make_reservation_from_block(room_id:12, customer: "Jesse")
  hotel.make_block(date_range: range1, room_ids:[19,20], new_nightly_rate:125)
else
  puts "that's nonsense, we're quitting"
  exit()
end

# ######## 
puts "\nSHOWING hotel.all_reservations..."
puts hotel.all_reservations

puts "\nSHOWING hotel.all_blocks..."
puts hotel.all_blocks

# puts "\nSHOWING hotel.all_rooms..."
# puts hotel.all_rooms
########

stay_in_loop = true
while stay_in_loop
  puts "\n############################"
  hotel.show_menu
  puts "############################\n"
  choice = hotel.prompt_for_input
  
  case choice
  when "A"
    puts "LISTING ALL ROOMS"
    puts hotel.list_all_rooms
    
  when "B"
    puts "LISTING ALL AVAILABLE ROOMS FOR DATE RANGE"
    date_range = hotel.prompt_for_date_range
    puts hotel.list_available_rooms(date_range)
    
  when "C"
    puts "MAKING A RESERVATION"
    date_range = hotel.prompt_for_date_range
    customer = hotel.prompt_for_input(statement: "What's the customer's name?")
    new_nightly_rate = hotel.prompt_for_new_nightly_rate
    new_res = hotel.make_reservation(date_range:date_range, customer: customer, new_nightly_rate: new_nightly_rate)
    puts "CONFIRM: #{new_res}"
    
  when "D"
    puts "LISTING ALL RESERVATIONS FOR A DATE"
    date = hotel.prompt_for_date
    puts hotel.list_reservations(date)
    
  when "E"
    puts "Getting cost"
    res_id = hotel.prompt_for_input(statement: "WHAT IS THE RESERVATION ID?")
    puts "Total is $#{(hotel.get_cost(res_id.to_i))}"
    
  when "F"
    puts "MAKING A BLOCK"
    date_range = hotel.prompt_for_date_range
    puts "Which rooms would you like for the block?"
    room_ids = hotel.prompt_for_array_of_ids
    new_nightly_rate = hotel.prompt_for_new_nightly_rate
    new_block = hotel.make_block(date_range:date_range, room_ids:room_ids, new_nightly_rate:new_nightly_rate)
    puts "CONFIRM: #{new_block}"
    
  when "G"
    puts "MAKING A RESERVATION FROM BLOCK"
    block_id = (hotel.prompt_for_input(statement: "What is the block id?")).to_i
    puts hotel.list_available_rooms_from_block(block_id)
    room_id = hotel.prompt_for_input(statement: "Which room do you want?")
    customer = hotel.prompt_for_input(statement: "What's the customer's name?")
    new_res = hotel.make_reservation_from_block(room_id:room_id.to_i, block_id: block_id, customer:customer)
    puts "CONFIRM: #{new_res}"
    
  when "H"
    puts "LIST AVAILABLE ROOMS FROM BLOCK"
    block_id = hotel.prompt_for_input(statement: "What is the block id?")
    puts hotel.list_available_rooms_from_block(block_id.to_i)
    
  when "I"
    puts "CHANGE ROOM RATE"
    room_id = (hotel.prompt_for_input(statement: "What is the room id?")).to_i
    new_nightly_rate = hotel.prompt_for_new_nightly_rate
    hotel.change_room_rate(room_id:room_id, new_nightly_rate:new_nightly_rate)
    room = hotel.get_room_from_id(room_id)
    puts "CONFIRMING: #{room_id}'s new rate is now $#{room.nightly_rate}"
    
  when "Q"
    print "\nLOGGING OFF, DO YOU WANT TO SAVE? >>> "
    choice = gets.chomp
    if choice[0].upcase == "Y"
      puts "ok, writing over all previously saved data with data from this session"
      hotel.write_csv(all_rooms_target:ALL_ROOMS_CSV, all_blocks_target:ALL_BLOCKS_CSV, all_reservations_target:ALL_RESERVATIONS_CSV)
    elsif choice[0].upcase == "N"
      puts "ok, not saving"
    else 
      puts "that's nonsense, we're quitting anyway"
    end
    stay_in_loop = false
  end
end


puts
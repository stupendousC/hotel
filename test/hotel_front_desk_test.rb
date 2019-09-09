require_relative 'test_helpers.rb'

describe "### HOTEL_FRONT_DESK CLASS ###" do

  describe "Hotel_front_desk.new" do 

    let (:hotel1) { Hotel_front_desk.new }

    it "Can create Hotel_front_desk instance " do
      expect(hotel1).must_be_kind_of Hotel_front_desk
    end

    it "Should have 20 Room objs made, and stored in @all_rooms array" do
      expect(hotel1.all_rooms.length).must_equal 20
      expect(hotel1.all_rooms).must_be_kind_of Array
    end

    it "Should have default @all_reservations of []" do
      assert(hotel1.all_reservations == [])
    end

    it "Should have default @all_blocks of []" do
      assert(hotel1.all_blocks == [])
    end

  end

  describe "Does .list_all_rooms work?" do
    it "Returned string should show all Room instances" do
      hotel2 = Hotel_front_desk.new(num_rooms_in_hotel: 3)
      manual_str = "LIST OF ALL ROOMS:\n  ROOM #1\n  ROOM #2\n  ROOM #3\n"
      print_out = hotel2.list_all_rooms
      assert(manual_str == print_out)
    end
  end

  describe "Does .make_reservation work?" do
    let (:hotel) { Hotel_front_desk.new }
    let (:empty_hotel) { Hotel_front_desk.new(num_rooms_in_hotel:0) }
    let (:today) { Date.today }
    let (:range1) { Date_range.new(start_date_obj: today, end_date_obj: today+2) }

    it "Raises error at args validation step" do
      expect{hotel.make_reservation( date_range: "garbage", customer: "trump" )}.must_raise ArgumentError
      # bad customer arg
      expect{hotel.make_reservation( date_range: range1, customer: "" )}.must_raise ArgumentError
      expect{hotel.make_reservation( date_range: range1, customer: 666 )}.must_raise ArgumentError
      expect{hotel.make_reservation( date_range: range1, customer: nil )}.must_raise ArgumentError
      # bad new_nightly_rate arg
      expect{hotel.make_reservation( date_range: range1, customer: "garbage", new_nightly_rate: "garbage")}.must_raise ArgumentError
      expect{hotel.make_reservation( date_range: range1, customer: "garbage", new_nightly_rate: 0.01)}.must_raise ArgumentError
      expect{hotel.make_reservation( date_range: range1, customer: "garbage", new_nightly_rate: -1)}.must_raise ArgumentError
    end

    describe "Does .find_avail_room work?" do
      it "Returns Room obj if a room is available" do
        should_be_a_room = hotel.find_avail_room(range1)
        assert(should_be_a_room.class == Room)
      end

      it "Returns nil if none available" do 
        should_be_nil = empty_hotel.find_avail_room(range1)
        assert(should_be_nil == nil)
      end
    end

    it "Raises error if no room available" do
      # just making sure nil from .find_avail_room gets carried to .make_reservation
      expect {empty_hotel.make_reservation(date_range: range1, customer: "ghost")}.must_raise ArgumentError
    end

    describe "Once room is found, proceed with correct behavior" do 
      let (:hotel) { Hotel_front_desk.new }
      let (:today) { Date.today }
      let (:range1) { Date_range.new(start_date_obj: today, end_date_obj: today+2) }
      let (:res1) { hotel.make_reservation(date_range: range1, customer: "Farnsworth", new_nightly_rate: 100) }

      it "Makes new Reservation obj with correct attribs assigned" do
        expect(res1).must_be_kind_of Reservation

        expected_new_id = Reservation.class_variable_get(:@@available_id)
        assert(res1.id == expected_new_id)
        assert(res1.date_range == range1)
        assert(res1.start_date == today)
        assert(res1.end_date == today+2)
        assert(res1.customer == "Farnsworth")
        assert(res1.new_nightly_rate == 100)  
      end

      it "Updates RoomObj.occupied_nights via make_unavail, and added ReservationObj to Room.all_reservations" do
        room = res1.room
        expect(room).must_be_kind_of Room

        assert(room.all_reservations.length == 1)
        assert(room.all_reservations.include? res1)
      end

      it "Updates Hotel obj's @all_reservations" do
        assert(hotel.all_reservations == [])
        res1
        assert(hotel.all_reservations.length == 1)
        assert(hotel.all_reservations[0] == res1)
      end
    end

  end

  describe "Does .get_cost work?" do
    let (:hotel) { Hotel_front_desk.new }
    let (:today) { Date.today }
    let (:range1) { Date_range.new(start_date_obj: today, end_date_obj: today+2) }
    let (:res1) { hotel.make_reservation(date_range: range1, customer: "Wernstrom") }
    let (:res2) { hotel.make_reservation(date_range: range1, customer: "Farnsworth", new_nightly_rate: 10) }

    it "Returns correct cost" do
      reservation1_id = res1.id
      cost1 = hotel.get_cost(reservation1_id)
      assert(cost1 == 400)

      reservation2_id = res2.id
      cost2 = hotel.get_cost(reservation2_id)
      assert(cost2 == 20)
    end

    it "Raises error if arg invalid" do
      bad_args = [ 666, "garbage", Object.new, [] ]
      bad_args.each do |bad_arg|
        expect{ hotel.get_cost(bad_arg) }.must_raise ArgumentError
      end
    end

  end

  describe "Does .list_reservations work?" do
    let (:hotel) { Hotel_front_desk.new }
    let (:today) { Date.today }
    let (:range1) { Date_range.new(start_date_obj: today, end_date_obj: today+10) }
    let (:res1) { hotel.make_reservation(date_range: range1, customer: "Wernstrom") }
    let (:res2) { hotel.make_reservation(date_range: range1, customer: "Farnsworth", new_nightly_rate: 10) }
    let (:block) { hotel.make_block(date_range: range1, room_ids: [18,19,20], new_nightly_rate:100) }


    it "Returns correct string if reservations exist for that date" do
      res1
      res2
      assert(hotel.all_reservations.length == 2)
      # checkout day should still be included in the reservation 
      checkout = today+9
      good_args = [ today, today+5, today+9 , checkout ]
      good_args.each do |good_arg|
        string = hotel.list_reservations(good_arg)
        expected_string = "\nLISTING RESERVATIONS FOR DATE #{good_arg}...\n  #{res1.to_s}\n  #{res2.to_s}"
        assert (string == expected_string)
      end
    end

    it "Returned correct string, with relevant Block indications" do
      block
      kif_res = hotel.make_reservation_from_block(room_id:18, customer: "Kif")
      wernstrom_res = res1
      
      string = hotel.list_reservations(today)
      expected_string = "\nLISTING RESERVATIONS FOR DATE 2019-09-08...\n  Reservation ##{kif_res.id} for Kif: Room#18, 2019-09-08 until 2019-09-18.  Total = $1000. *#{block.to_s}*\n  Reservation ##{wernstrom_res.id} for Wernstrom: Room##{wernstrom_res.room_id}, 2019-09-08 until 2019-09-18.  Total = $2000."  

      assert(hotel.all_reservations.length == 2)
      assert(hotel.all_reservations[0] == kif_res)
      assert(hotel.all_reservations[1] == wernstrom_res)
      assert(string == expected_string)
    end

    it "Returns correct string if no Reservations for that date" do
      assert(hotel.all_reservations.length == 0)
      string = hotel.list_reservations(Date.today)
      assert( string == "\nNO RESERVATIONS FOR DATE #{Date.today}" )
    end

    it "Raises error if bad date arg" do
      bad_args = [ 666, "garbage", Object.new, [], range1 ]
      bad_args.each do |bad_arg|
        expect{ hotel.list_reservations(bad_arg) }.must_raise ArgumentError
      end
    end
  end

  describe "Does .list_available_rooms work?" do
    let (:airbnb) { Hotel_front_desk.new(num_rooms_in_hotel: 1) }
    let (:hotel) { Hotel_front_desk.new(num_rooms_in_hotel: 10) }
    let (:today) { Date.today }
    let (:range1) { Date_range.new(start_date_obj: today, end_date_obj: today+10) }
    let (:res_airbnb) { airbnb.make_reservation(date_range: range1, customer: "Fry") }
    let (:res_hotel) { hotel.make_reservation(date_range: range1, customer: "Bender", new_nightly_rate: 10) }
  

    it "Returns expected string when all or some rooms available" do
      ### Scenario: 10-room hotel ###
      # expecting all 10 Rooms to be returned, b/c no reservations
      string = hotel.list_available_rooms(range1)
      assert(string.class == String)
      expected_string = "\nLISTING AVAILABLE ROOMS FOR #{range1.start_date} TO #{range1.end_date}...\n  Room #1\n  Room #2\n  Room #3\n  Room #4\n  Room #5\n  Room #6\n  Room #7\n  Room #8\n  Room #9\n  Room #10"
      assert (string == expected_string)
      # now expecting 19 rooms to be returned
      res_hotel
      string = hotel.list_available_rooms(range1)
      expected_string = "\nLISTING AVAILABLE ROOMS FOR #{range1.start_date} TO #{range1.end_date}...\n  Room #2\n  Room #3\n  Room #4\n  Room #5\n  Room #6\n  Room #7\n  Room #8\n  Room #9\n  Room #10"
      assert(string == expected_string)

      ### Scenario: airbnb ###
      # start with just 1 room
      string = airbnb.list_available_rooms(range1)
      expected_string = "\nLISTING AVAILABLE ROOMS FOR #{range1.start_date} TO #{range1.end_date}...\n  Room #1"
      assert(string == expected_string)
      # see change when the 1 room becomes unavailable
      res_airbnb
      string = airbnb.list_available_rooms(range1)
      expected_string =  "\nNO ROOMS AVAILABLE FOR #{range1.start_date} TO #{range1.end_date}"
      assert(string == expected_string)

      # is the room available on clashing dates?
      clash = Date_range.new(start_date_obj: today-1, end_date_obj: today+1)
      string = airbnb.list_available_rooms(clash)
      assert(string = expected_string)
      # is the room available on non-clashing dates?
      future = Date_range.new(start_date_obj: today+100, end_date_obj: today+105)
      string = airbnb.list_available_rooms(future)
      expected_string = "\nLISTING AVAILABLE ROOMS FOR #{future.start_date} TO #{future.end_date}...\n  Room #1"
      assert(string == expected_string)
    end

    it "Returns expected string if no rooms available" do
      res_airbnb
      string = airbnb.list_available_rooms(range1)
      expected_string = "\nNO ROOMS AVAILABLE FOR #{range1.start_date} TO #{range1.end_date}"
      assert(string == expected_string)
    end

    it "Raises error if bad date arg" do
      bad_args = [ 666, "garbage", Object.new, [], Date.today ]
      bad_args.each do |bad_arg|
        expect{ airbnb.list_available_rooms(bad_arg) }.must_raise ArgumentError
      end
    end
  end

  describe "Does get_room_from_id work?" do
    let (:hotel) { Hotel_front_desk.new }

    it "Returns correct Room obj" do
      room = hotel.get_room_from_id(1)
      assert(room.class == Room)
      assert(room.id == 1)
    end

    it "Raises error with bad args" do
      bad_args = [0, -1, 1.2, 3000, "garbage"]
      bad_args.each do |bad_arg|
        expect{ hotel.get_room_from_id(bad_arg) }.must_raise ArgumentError
      end
    end
  end

  describe "Does get_rooms_from_ids work?" do
    let (:hotel) { Hotel_front_desk.new }

    it "Returns array of correct Room objs" do
      rooms = hotel.get_rooms_from_ids([1,2,3,4,5])
      assert(rooms.class == Array)
      assert(rooms.length == 5)
      rooms.each do |room|
        assert(room.class == Room)
      end
    end

    it "Raises error with bad args" do
      # only need to eval *args as a whole 
      # b/c each individual arg is checked by get_room_from_id, which is inc'd in this method
      expect{ hotel.get_rooms_from_ids([1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21]) }.must_raise ArgumentError
      expect{ hotel.get_rooms_from_ids([1,1]) }.must_raise ArgumentError
    end
  end

  describe "Does get_block_from_id work?" do
    let (:hotel) { Hotel_front_desk.new }
    let (:today) { Date.today }
    let (:checkout) {today + 10}
    let (:range1) { Date_range.new(start_date_obj: today, end_date_obj: checkout) }
    let (:block) { hotel.make_block(date_range: range1, room_ids: [1,2,3], new_nightly_rate: 10) } 

    it "Returns correct Block obj" do
      returned_block = hotel.get_block_from_id(block.id)
      assert(returned_block == block)
    end

    it "Raises error with bad args" do
      bad_args = [0, -1, 1.2, 3000, "garbage"]
      bad_args.each do |bad_arg|
        expect{ hotel.get_block_from_id(bad_arg) }.must_raise ArgumentError
      end
    end

  end


  describe "Does make_block work?" do
    let (:hotel) { Hotel_front_desk.new }
    let (:airbnb) { Hotel_front_desk.new(num_rooms_in_hotel: 1) }
    let (:today) { Date.today }
    let (:checkout) {today + 10}
    let (:range1) { Date_range.new(start_date_obj: today, end_date_obj: checkout) }
    let (:no_clash1) { Date_range.new(start_date_obj: checkout, end_date_obj: checkout+3) }
    let (:no_clash2) { Date_range.new(start_date_obj: today-3, end_date_obj: today) }
    
    it "Returns Block with correct attribs" do
      block = hotel.make_block(date_range: range1, room_ids: [1, 20], new_nightly_rate: 100)
      assert(hotel.all_blocks.length == 1)
      assert(hotel.all_blocks[0] == block)
      assert(block.class == Block)
      assert(block.date_range == range1)
      assert(block.new_nightly_rate == 100)
      assert(block.occupied_rooms == [])
      assert(block.occupied_room_ids == [])
      assert(block.unoccupied_room_ids == [1,20])
      assert(block.unoccupied_rooms[0].id == 1)
      assert(block.unoccupied_rooms[1].id == 20)
      block.unoccupied_rooms.each do |room|
        assert(room.class == Room)
      end
    end
    
    it "Ensure make_block updates availability of affected Room objs" do
      block = hotel.make_block(date_range: range1, room_ids: [1, 20], new_nightly_rate: 100)
      room1 = block.unoccupied_rooms[0]
      room20 = block.unoccupied_rooms[1]
      [room1, room20].each do |room|
        assert(room.occupied_nights.length == 10)
        room.occupied_nights.each do |occupied_night|
          assert(range1.date_in_range?(occupied_night))
          if occupied_night == checkout
            assert(false, msg = "checkout day shouldn't go into Room obj's @occupied_nights")
          end
        end
      end
    end
    
    it "Raises error if room unavailable" do
      reservation = airbnb.make_reservation(date_range: range1, customer: "Fry")
      clash1 = Date_range.new(start_date_obj: today-1, end_date_obj: today+1)
      clash2 = Date_range.new(start_date_obj: checkout-1, end_date_obj: checkout+1)
      clash3 = Date_range.new(start_date_obj: today+3, end_date_obj: checkout-3)
      clash4 = Date_range.new(start_date_obj: today-3, end_date_obj: checkout+3)
      
      bad_args = [range1, clash1, clash2, clash3, clash4]
      bad_args.each do |bad_arg|
        expect{ airbnb.make_block(date_range: bad_arg, room_ids: [1], new_nightly_rate: 50) }.must_raise ArgumentError
      end
    end
    
    it "Existing block does not interfere w/ single room reservation for non-clashing dates" do
      block = airbnb.make_block(date_range: range1, room_ids: [1], new_nightly_rate:50)
      
      [no_clash1, no_clash2].each do |good_arg|
        assert(airbnb.make_reservation(date_range: good_arg, customer: "Fry"))
      end
    end
    
    it "Existing block does not interfere w/ another block's reservation for non-clashing dates" do
      block = airbnb.make_block(date_range: range1, room_ids: [1], new_nightly_rate:50)

      [no_clash1, no_clash2].each do |good_arg|
        assert(airbnb.make_block(date_range: good_arg, room_ids: [1], new_nightly_rate: 30))
      end
    end
    
    
    it "Raises error with bad args" do
      bad_args = ["garbage", 1, Date.today, Object.new]
      bad_args.each do |bad_arg|
        expect{ hotel.make_block(date_range: bad_arg, room_ids: [1], new_nightly_rate: 100) }.must_raise ArgumentError
      end
      
      bad_args = ["garbage", 1, [], [1,2,3,4,5,6], [0], [1000]]
      bad_args.each do |bad_arg|
        expect{ hotel.make_block(date_range: range1, room_ids: bad_arg, new_nightly_rate: 100) }.must_raise ArgumentError
      end
      
      bad_args = ["garbage", 0, 1.23, -1, 1000]
      bad_args.each do |bad_arg|
        expect{ hotel.make_block(date_range: range1, room_ids: [1], new_nightly_rate: bad_arg) }.must_raise ArgumentError
      end
    end
  end

  describe "Does make_reservation_from_block work?" do
    let (:hotel) { Hotel_front_desk.new }
    let (:today) { Date.today }
    let (:checkout) {today + 10}
    let (:range1) { Date_range.new(start_date_obj: today, end_date_obj: checkout) }
    let (:block) { hotel.make_block(date_range: range1, room_ids: [1,2,3], new_nightly_rate: 10) }

    it "Given good args, makes new Reservation and updates all attribs correctly" do
      block
      reservation = hotel.make_reservation_from_block(room_id:1, customer: "Bender")
      assert(reservation.class == Reservation)
      assert(reservation.room_id == 1)
      assert(reservation.cost == 100)
      assert(reservation.customer == "Bender")
      assert(reservation.date_range == range1)
      assert(reservation.new_nightly_rate == 10)
      assert(reservation.block == block)

      # Did Block obj's own attributes update correctly?
      assert(block.unoccupied_room_ids == [2,3])
      assert(block.unoccupied_rooms[0].id == 2)
      assert(block.unoccupied_rooms[1].id == 3)
      assert(block.occupied_room_ids == [1])
      assert(block.occupied_rooms[0].id == 1)
      assert(block.all_reservations.length == 1)
      assert(block.all_reservations[0] == reservation)

      # Did Room objs' attribs update correctly?
      room1 = hotel.get_room_from_id(1)
      room2 = hotel.get_room_from_id(2)
      room3 = hotel.get_room_from_id(3)
      assert(room1.all_reservations.include? reservation)
      refute(room2.all_reservations.include? reservation)
      refute(room3.all_reservations.include? reservation)
    end

    it "Raises error with bad args" do
      block
      bad_args = ["garbage", 20, 21]
      bad_args.each do |bad_arg|
        expect{ hotel.make_reservation_from_block(room_id: bad_arg, customer: "Flexo") }.must_raise ArgumentError
      end

      bad_args = ["", nil, 10000, Object.new]
      bad_args.each do |bad_arg|
        expect{ hotel.make_reservation_from_block(room_id: 1, customer: bad_arg) }.must_raise ArgumentError
      end
    end

    it "Raises error if room is already booked" do
      block
      hotel.make_reservation_from_block(room_id:1, customer: "Bender")
      
      expect{ hotel.make_reservation_from_block(room_id:1, customer: "Hedonismbot") }.must_raise ArgumentError
    end
  end

  describe "Does list_available_rooms_from_block work?" do
    let (:hotel) { Hotel_front_desk.new }
    let (:today) { Date.today }
    let (:range1) { Date_range.new(start_date_obj: today, end_date_obj: today+2) }
    let (:block) { hotel.make_block(date_range: range1, room_ids: [1,2,3], new_nightly_rate: 100) }
    let (:string) { hotel.list_available_rooms_from_block(block.id) }

    it "Returns expected string if all rooms available" do
      expected_string = "\nLISTING AVAILABLE ROOMS FOR BLOCK #{block.id}...\n  Room #1\n  Room #2\n  Room #3"
      assert(string == expected_string)
    end

    it "Returns expected string if some rooms available" do
      expected_string = "\nLISTING AVAILABLE ROOMS FOR BLOCK #{block.id}...\n  Room #2\n  Room #3"
      hotel.make_reservation_from_block(room_id: 1, customer: "Calculon")
      assert(string == expected_string)
    end

    it "Returns expected string if no rooms available" do
      expected_string = "\nNO ROOMS AVAILABLE FOR BLOCK #{block.id}"
      hotel.make_reservation_from_block(room_id: 1, customer: "Calculon")
      hotel.make_reservation_from_block(room_id: 2, customer: "Mafia Don Bot")
      hotel.make_reservation_from_block(room_id: 3, customer: "Roberto")
      assert(string == expected_string)

      
    end
  
  end

end
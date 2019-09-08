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

    it "Returns list of Reservations if they exist for that date" do
      res1
      res2
      assert(hotel.all_reservations.length == 2)
      good_args = [ today, today+5, today+10 ]
      good_args.each do |good_arg|
        results = hotel.list_reservations(good_arg) 
        assert(results.length == 2)
        assert(results.include? res1)
        assert(results.include? res2)
      end
    end

    it "Returns nil if no Reservations for that date" do
      assert(hotel.all_reservations.length == 0)
      assert(hotel.list_reservations(Date.today) == nil)
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
    let (:hotel) { Hotel_front_desk.new }
    let (:today) { Date.today }
    let (:range1) { Date_range.new(start_date_obj: today, end_date_obj: today+10) }
    let (:res_airbnb) { airbnb.make_reservation(date_range: range1, customer: "Fry") }
    let (:res_hotel) { hotel.make_reservation(date_range: range1, customer: "Bender", new_nightly_rate: 10) }

    it "Returns expected array of Room objs" do
      ### Scenario: 20-room hotel ###
      # expecting all 20 Rooms to be returned, b/c no reservations
      should_have_20 = hotel.list_available_rooms(range1)
      assert(should_have_20.length == 20)
      20.times do |index|
        assert(should_have_20[index].class == Room)
        assert(should_have_20[index].id == (index+1))
      end
      res_hotel
      # now expect 19 rooms to be returned
      assert(hotel.list_available_rooms(range1).length == 19)

      ### Scenario: airbnb ###
      # see change when the 1 room becomes unavailable
      should_have_1 = airbnb.list_available_rooms(range1)
      assert(should_have_1.length == 1)
      res_airbnb
      # is the room available on the exact same dates?
      should_be_nil = airbnb.list_available_rooms(range1) 
      assert(should_be_nil == nil)
      # is the room available on clashing dates?
      clash = Date_range.new(start_date_obj: today-1, end_date_obj: today+1)
      should_also_be_nil = airbnb.list_available_rooms(clash)
      assert(should_also_be_nil == nil)

      # is the room available on non-clashing dates?
      future = Date_range.new(start_date_obj: today+100, end_date_obj: today+105)
      should_have_1 = airbnb.list_available_rooms(future)

      assert(should_have_1.length == 1)
    end

    it "Returns nil if no rooms available" do
      res_airbnb
      assert(airbnb.list_available_rooms(range1) == nil)
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
      expect{ hotel.get_rooms_from_ids(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21) }.must_raise ArgumentError
      expect{ hotel.get_rooms_from_ids(1,1) }.must_raise ArgumentError
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
      assert(reservation.in_block == true)
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




end
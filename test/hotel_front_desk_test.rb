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
      expect(hotel1.all_reservations.length).must_equal 0
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
  
end
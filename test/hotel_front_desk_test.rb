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
    
    it "Returns nil if no room available" do
      # just making sure nil from .find_avail_room gets carried to .make_reservation
      should_be_nil = empty_hotel.make_reservation(date_range: range1, customer: "ghost")
      assert(should_be_nil == nil)
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
  
  
  
  
  
  
  
  describe "Does .calc_cost work?" do
    # edge: invalid arg
  end
  
  describe "Does .list_reservation work?" do
    # edge: invalid date
  end
  
end
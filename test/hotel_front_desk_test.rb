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
    # edge: what if start_date = endDate
    # edge what if startdate > endDate
  end

  describe "Does .calc_cost work?" do
    # edge: invalid arg
  end

  describe "Does .list_reservation work?" do
    # edge: invalid date
  end

end
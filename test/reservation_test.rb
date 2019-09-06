require_relative 'test_helpers.rb'

describe "### RESERVATION CLASS ###" do

  describe "Does Reservation.new() work?" do
    let (:today) { Date.today }
    let (:range1) { Date_range.new(start_date_obj: today, end_date_obj: today+2) }
    
    it "Can make Reservation object w/ correct attribs assigned" do
      expected_new_id = 1 + Reservation.class_variable_get(:@@available_id)
      res1 = Reservation.new(room_id: 20, date_range: range1)
      
      expect(res1).must_be_kind_of Reservation

      assert(res1.id == expected_new_id)
      assert(res1.room_id == 20)
      assert(res1.date_range == range1)
      assert(res1.start_date == today)
      assert(res1.end_date == today+2)
      assert(res1.new_nightly_rate == nil)
    end

######## ACTUALLY I'M GOING TO MOVE ALL VALIDATION TO HOTEL_FRONT_DESK

    it "Raises error with bad args" do
      expect{Reservation.new(room_id: 20, date_range: "garbage")}.must_raise ArgumentError
      expect{Reservation.new(room_id: 20, date_range: range1, new_nightly_rate: 1.2)}.must_raise ArgumentError
      expect{Reservation.new(room_id: 20, date_range: range1, new_nightly_rate: 0)}.must_raise ArgumentError
      expect{Reservation.new(room_id: 20, date_range: range1, new_nightly_rate: -1)}.must_raise ArgumentError
      expect{Reservation.new(room_id: 20, date_range: range1, new_nightly_rate: "garbage")}.must_raise ArgumentError
      
    end
  end





  
  describe "Does Reservation.generate_id work?" do
    it "@@available_id scrolls by 1 after each assignment" do
      expected_new_id = 1 + Reservation.class_variable_get(:@@available_id)
      3.times do
        new_id = Reservation.generate_id
        assert(new_id == expected_new_id)
        expected_new_id += 1
      end
    end
  end

  describe "Does .calc_cost() work?" do
    it "Calculates cost correctly" do
    end

    it "Raises error with bad args" do
    end

  end


end
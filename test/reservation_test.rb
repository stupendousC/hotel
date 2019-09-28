require_relative 'test_helpers.rb'

describe "### RESERVATION CLASS ###" do
  let (:today) { Date.today }
  let (:range1) { DateRange.new(start_date_obj: today, end_date_obj: today+2) }
  
  describe "Does Reservation.new() work?" do
    # all arg validations done by precursor method HotelFrontDesk#make_reservation
    it "Can make Reservation object w/ correct attribs assigned" do
      expected_new_id = 1 + Reservation.class_variable_get(:@@available_id)
      res1 = Reservation.new(room_id: 20, date_range: range1, customer: "Morbo")
      
      expect(res1).must_be_kind_of Reservation
      
      assert(res1.id == expected_new_id)
      assert(res1.room_id == 20)
      assert(res1.date_range == range1)
      assert(res1.start_date == today)
      assert(res1.end_date == today+2)
      assert(res1.customer == "Morbo")
      assert(res1.new_nightly_rate == nil)
      assert(res1.block == nil)
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
  
  it "Does Reservation.set_available_id work?" do
    curr_id = Reservation.class_variable_get(:@@available_id)
    new_id = curr_id + 50 
    Reservation.set_available_id(new_id)
    assert(new_id == Reservation.class_variable_get(:@@available_id))
  end
  
  describe "Does .calc_cost() work?" do
    let(:res1) { Reservation.new(room_id: 20, date_range: range1, customer: "Fry") }
    
    it "Calculates cost correctly" do
      assert(res1.calc_cost == 400)
      
      res_cheap = Reservation.new(room_id: 19, new_nightly_rate: 1, date_range: range1, customer: "Zoidberg")
      assert(res_cheap.calc_cost == 2)
    end
  end
  
end
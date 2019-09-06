require_relative 'test_helpers.rb'

describe "### RESERVATION CLASS ###" do

  describe "Does Reservation.new() work?" do
    # all arg validations done by precursor method Hotel_front_desk#make_reservation
    let (:today) { Date.today }
    let (:range1) { Date_range.new(start_date_obj: today, end_date_obj: today+2) }
    
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
    let (:today) { Date.today }
    let (:range1) { Date_range.new(start_date_obj: today, end_date_obj: today+2) }
    let(:res1) { Reservation.new(room_id: 20, date_range: range1, customer: "Fry") }

    it "Calculates cost correctly" do
      assert(res1.calc_cost == 400)

      res_cheap = Reservation.new(room_id: 19, new_nightly_rate: 1, date_range: range1, customer: "Zoidberg")
      assert(res_cheap.calc_cost == 2)
    end
  end

end
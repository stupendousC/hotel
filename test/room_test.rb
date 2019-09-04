require_relative 'test_helpers.rb'

describe "### ROOM CLASS ###" do

  describe "Room.new" do 

    it "Can create Room instance " do
      expect(Room.new(id: 1)).must_be_kind_of Room
    end

    it "Raises error if bad args given" do
      # give bad id
      bad_ids = [-1, 0, 1.1, "poo", [], {}]
      bad_ids.each do |bad_arg|
        expect{Room.new(id: bad_arg)}.must_raise ArgumentError
      end

      # give bad rate
      bad_rates = [-1, 0, 1.1, "poo", [], {}]
      bad_ids.each do |bad_arg|
        expect{Room.new(id: 2, nightly_rate: bad_arg)}.must_raise ArgumentError
      end    
    end

    it "Can access attributes" do
      outhouse = Room.new(id:3)
      assert(outhouse.nightly_rate == 200)
      assert(outhouse.id == 3)
      assert(outhouse.calendar_hash == {})
    end
  end


  describe "Room#check_avail()" do
    it "Works for 1 date" do
    end

    it "Works for a Date Range obj" do
    end

    it "Raises error if none or both args provided" do
    end
  end

  describe "Room#make_unavail()" do
    it "Works for 1 date" do
    end

    it "Works for a Date Range obj" do
    end

    it "Raises error if none or both args provided" do
    end
  end


end

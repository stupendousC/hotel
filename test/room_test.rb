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
      assert(outhouse.occupied_nights == [])
    end
  end


  describe "Room#check_avail()" do
    let (:room) { Room.new(id:4) }
    let (:today) { Date.new(2019,9,5)}
    let (:yesterday) { Date.new(2019,9,4)}
    let (:tomorrow) { Date.new(2019,9,6) }

    it "Returns T when expected" do

    end

    it "Raises error on edge cases" do
      refute(room.check_avail(today, today))
      refute(room.check_avail("garbage", "crap"))
      refute(room.check_avail(tomorrow, yesterday))
      
    end
  end

  describe "Room#make_unavail()" do
    it "Returns T when expected" do
    end

    it "Raises error on edge cases" do
    end
  end


end

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


  describe "Room#check_avail?" do
    let (:room) { Room.new(id:4) }
    let (:today) { Date.new(2019,9,5)}
    let (:yesterday) { Date.new(2019,9,4)}
    let (:tomorrow) { Date.new(2019,9,6) }
    let (:random_checkout) {today + rand(1..10)}

    it "Returns T when @occupied_nights empty" do
      assert(room.check_avail?(start_date_obj: yesterday, end_date_obj: tomorrow))
      assert(room.check_avail?(start_date_obj: today, end_date_obj: today + rand(1..5)))
    end

    it "Returns T when not clashing with non-empty @occupied_nights" do
      # this block depends on a bug-free .make_unavail 
      room.make_unavail(start_date_obj: today, end_date_obj: random_checkout)
      assert(room.check_avail?(start_date_obj: today+10, end_date_obj: today+12))

      # person A checking out on end_date shouldn't interfere w/ person B checking in the same night
      room.make_unavail(start_date_obj: today+20, end_date_obj: today + 30)
      assert(room.check_avail?(start_date_obj: today+30, end_date_obj: today+40))
    end

    it "Returns F when clashing with non-empty @occupied_nights" do
      # this block depends on a bug-free .make_unavail 
      room.make_unavail(start_date_obj: today, end_date_obj: today+30)

      refute(room.check_avail?(start_date_obj: yesterday, end_date_obj: tomorrow))
      refute(room.check_avail?(start_date_obj: tomorrow, end_date_obj: tomorrow+1))
      refute(room.check_avail?(start_date_obj: tomorrow, end_date_obj: tomorrow+60))
    end

    it "Raises error on edge cases" do
      expect{room.check_avail?(start_date_obj: today, end_date_obj: today)}.must_raise ArgumentError
      expect{room.check_avail?(start_date_obj: "garbage", end_date_obj: "crap")}.must_raise ArgumentError
      expect{room.check_avail?(start_date_obj: tomorrow, end_date_obj: yesterday)}.must_raise ArgumentError
    end
  end


  describe "Room#make_unavail()" do
    let (:room) { Room.new(id:4) }
    let (:today) { Date.new(2019,9,5)}
    let (:yesterday) { Date.new(2019,9,4)}
    let (:tomorrow) { Date.new(2019,9,6) }
    let (:random_checkout) {today + rand(1..10)}

    it "Updates @occupied_nights as expected" do 
      assert(room.occupied_nights.length == 0, msg = "starting with empty @occupied_nights")
      checkout = today + rand(1..10)
      room.make_unavail(start_date_obj: today, end_date_obj: random_checkout)
      assert(room.occupied_nights.length == (random_checkout - today))

      all_days = [today, random_checkout-1]
      all_days.each do |day|
        assert(room.occupied_nights.include? day)
      end
    end

    it "Raises error on edge cases" do
      # normally, in hotel_front_desk.rb we'd have ran .check_avail? before anyway
      # but i'm checking just in case someone wants to call .make_unavail without checking
      expect{room.make_unavail(start_date_obj: today, end_date_obj: today)}.must_raise ArgumentError
      expect{room.make_unavail(start_date_obj: "garbage", end_date_obj: "crap")}.must_raise ArgumentError
      expect{room.make_unavail(start_date_obj: tomorrow, end_date_obj: yesterday)}.must_raise ArgumentError
    end
  end


end

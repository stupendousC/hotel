require_relative 'test_helpers.rb'

describe "### ROOM CLASS ###" do

  describe "Room.new" do 

    it "Can create Room instance with correct attribs" do
      room = Room.new(id: 1)
      expect(room).must_be_kind_of Room
      assert(room.nightly_rate == STANDARD_RATE)
      assert(room.id == 1)
      assert(room.occupied_nights == [])
      assert(room.all_reservations == [])
      assert(room.all_blocks == [])

      room_cheap = Room.new(id: 2, nightly_rate: 10)
      assert(room_cheap.nightly_rate == 10)
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
  end


  describe "Room#check_avail?" do
    let (:room) { Room.new(id:4) }
    let (:today) { Date.today }
    let (:random_checkout) {today + rand(1..10)}
    let (:yesterday_to_today) { Date_range.new(start_date_obj: today-1, end_date_obj: today) }
    let (:yesterday_to_tomorrow) { Date_range.new(start_date_obj: today-1, end_date_obj: today+1) }
    let (:today_to_random) { Date_range.new(start_date_obj: today, end_date_obj: today + rand(1..5)) }

    it "Returns T when @occupied_nights empty" do
      assert(room.check_avail?(yesterday_to_today))
      assert(room.check_avail?(today_to_random))
    end

    it "Returns T when not clashing with non-empty @occupied_nights" do
      # this block depends on a bug-free .make_unavail 
      room.make_unavail(today_to_random)
      safe = Date_range.new(start_date_obj: today+10, end_date_obj: today + 12)
      assert(room.check_avail?(safe))

      # person A checking out on end_date shouldn't interfere w/ person B checking in the same night
      future1 = Date_range.new(start_date_obj: today+20, end_date_obj: today + 30)
      room.make_unavail(future1)
      future2 = Date_range.new(start_date_obj: today+30, end_date_obj: today + 40)
      assert(room.check_avail?(future2))
    end

    it "Returns F when clashing with non-empty @occupied_nights" do
      # this block depends on a bug-free .make_unavail 
      taken = Date_range.new(start_date_obj: today, end_date_obj: today + 30)
      room.make_unavail(taken)

      refute(room.check_avail?(yesterday_to_tomorrow))

      tomorrow_plus_one = Date_range.new(start_date_obj: today+1, end_date_obj: today+2)
      refute(room.check_avail?(tomorrow_plus_one))
      tomorrow_plus_hundred = Date_range.new(start_date_obj: today+1, end_date_obj: today+100)
      refute(room.check_avail?(tomorrow_plus_hundred))
    end

    it "Raises error on edge cases" do
      expect{room.check_avail?(Date_range.new(start_date_obj: today, end_date_obj: today))}.must_raise ArgumentError
      expect{room.check_avail?(Date_range.new(start_date_obj: today+1, end_date_obj: today-1))}.must_raise ArgumentError
    end
  end


  describe "Room#make_unavail()" do
    let (:room) { Room.new(id:4) }
    let (:today) { Date.today }
    let (:random_checkout) {today + rand(1..10)}
    let (:yesterday_to_today) { Date_range.new(start_date_obj: today-1, end_date_obj: today) }
    let (:today_to_random) { Date_range.new(start_date_obj: today, end_date_obj: random_checkout) }

    it "Updates @occupied_nights as expected" do 
      assert(room.occupied_nights.length == 0, msg = "starting with empty @occupied_nights")
      room.make_unavail(today_to_random)
      assert(room.occupied_nights.length == (random_checkout - today))

      all_days = [today, random_checkout-1]
      all_days.each do |day|
        assert(room.occupied_nights.include? day)
      end
      refute(room.occupied_nights.include? random_checkout)
    end

    it "Raises error on edge cases" do
      expect{room.make_unavail(Date_range.new(start_date_obj: today, end_date_obj: today))}.must_raise ArgumentError
      expect{room.make_unavail(Date_range.new(start_date_obj: "garbage", end_date_obj: "crap"))}.must_raise ArgumentError
      expect{room.make_unavail(Date_range.new(start_date_obj: today + 1, end_date_obj: today - 1))}.must_raise ArgumentError
    end
  end

  describe "Room#add_reservation" do
    let (:room) { Room.new(id:4) }
    let (:wrong_room) { Room.new(id:20) }
    let (:today) { Date.today }
    let (:random_checkout) {today + rand(1..10)}
    let (:yesterday_to_today) { Date_range.new(start_date_obj: today-1, end_date_obj: today) }
    let (:today_to_random) { Date_range.new(start_date_obj: today, end_date_obj: random_checkout) }
    let (:reservation) { Reservation.new(room_id: 4, date_range: today_to_random, customer: "Leela") }
    it "Raises error if bad arg" do
      expect{room.add_reservation("garbage")}.must_raise ArgumentError
      expect{wrong_room.add_reservation(reservation)}.must_raise ArgumentError
    end

    it "Correctly adds Reservation obj to @all_reservations" do
      room.add_reservation(reservation)
      assert(room.all_reservations.length == 1)
      assert(room.all_reservations[0].class == Reservation)
      assert(room.all_reservations[0].id == reservation.id)
    end
  end


end

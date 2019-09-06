require_relative 'test_helpers.rb'

describe "### DATE_RANGE CLASS ###" do

  describe "Does Date_range.new() work?" do
    let (:today) { Date.today}
    let (:tomorrow) { today + 1 }
    let (:date_range1) { Date_range.new( start_date_obj: today, end_date_obj: today + 3) }

    it "Can make Date_range object" do
      expect(date_range1).must_be_kind_of Date_range
    end

    it "Raises error with bad args" do
      # bad DataType
      expect{Date_range.new(666, today)}.must_raise ArgumentError
      expect{Date_range.new(today, 666)}.must_raise ArgumentError
      expect{Date_range.new(Object.new, Array.new)}.must_raise ArgumentError
      # bad logic
      expect{Date_range.new(tomorrow, today)}.must_raise ArgumentError

    end

    it "Can access attributes correctly" do
      assert(date_range1.start_date == today)
      assert(date_range1.end_date == today + 3)
    end
  end

  describe "Does date_in_range? work?" do
    let (:today) { Date.today}
    let (:date_range1) { Date_range.new( start_date_obj: today, end_date_obj: today + 3) }

    it "Returns True when expected" do
      assert(date_range1.date_in_range?(today+2))
    end

    it "Returns False when expected" do
      refute(date_range1.date_in_range?(today+100))
      refute(date_range1.date_in_range?(today-100))
    end

    it "Raise error if bad args" do
      bad_args = [1, 0, -1, 1.2, "garbage", Object.new]
      bad_args.each do |bad_arg|
        expect{date_range1.date_in_range?(bad_arg)}.must_raise ArgumentError
      end
    end
  end

  describe "Does ranges_overlap? work?" do
    let (:today) { Date.today}
    let (:date_range1) { Date_range.new( start_date_obj: today, end_date_obj: today + 3) }

    it "Returns True when expected" do
      overlap1 = Date_range.new( start_date_obj: today-100, end_date_obj:today + 1)
      overlap2 = Date_range.new( start_date_obj: today+1, end_date_obj:today + 100)

      assert(date_range1.ranges_overlap?(overlap1))
      assert(date_range1.ranges_overlap?(overlap2))
      assert(date_range1.ranges_overlap?(date_range1))
    end

    it "Returns False when expected" do
      safe1 = Date_range.new( start_date_obj: today + 3, end_date_obj:today + 101)
      safe2 = Date_range.new( start_date_obj: today - 100, end_date_obj: today)
      safe3 = Date_range.new( start_date_obj: today + 100, end_date_obj:today + 101)

      refute(date_range1.ranges_overlap?(safe1))
      refute(date_range1.ranges_overlap?(safe2))
      refute(date_range1.ranges_overlap?(safe3))
    end

    it "Raise error if bad args" do
      bad_args = [1, 0, -1, 1.2, "garbage", Object.new]
      bad_args.each do |bad_arg|
        expect{date_range1.ranges_overlap?(bad_arg)}.must_raise ArgumentError
      end
    end
  end


end
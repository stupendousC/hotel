require_relative 'test_helper.rb'

describe "### VALIDATION MODULE ###" do
  before do
    class SampleClass < Object
      include Validation
    end
    @sampleClass = SampleClass.new
  end

  
  it "Does non_zero_integer? work" do
    assert(@sampleClass.non_zero_integer? 3)

    bad_args = ["", 0, {}, [], 6.66, Object.new]
    expect {
      bad_args.each { |bad_arg| @sampleClass.non_zero_integer?(bad_arg) }
    }.must_raise ArgumentError
  end

  it "Does non-blank_string? work" do
    assert(@sampleClass.non_blank_string? "xxx")
    
    bad_args = ["", 0, {}, [], 6.66, Object.new]
    expect {
      bad_args.each { |bad_arg| @sampleClass.non_blank_string?(bad_arg) }
    }.must_raise ArgumentError
  end

  it "Does available_id? work" do
    refute (@sampleClass.available_id?(1, [1,2,3]))
    assert (@sampleClass.available_id?(4, [1,2,3]))
    expect {@sampleClass.available_id?("X", [1,2,3])}.must_raise ArgumentError
  end
end
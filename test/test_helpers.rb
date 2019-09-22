require 'simplecov'
SimpleCov.start do
  add_filter 'test/'
end

require "minitest"
require "minitest/autorun"
require "minitest/reporters"
require 'csv'



Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new


require_relative '../lib/lib_requirements.rb'
require_relative '../lib/room.rb'
require_relative '../lib/hotelFrontDesk.rb'
require_relative '../lib/dateRange.rb'
require_relative '../lib/reservation.rb'
require_relative '../lib/block.rb'


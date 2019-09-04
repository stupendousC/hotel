require 'pry'   ### deactivate later???

require "minitest"
require "minitest/autorun"
require "minitest/reporters"

require 'simplecov'
SimpleCov.start

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

# require_relative your lib files here!
require_relative '../lib/lib_requirements.rb'
# require '../lib/block.rb'
require_relative '../lib/customer.rb'
# require '../lib/date.rb'
# require '../lib/date_range.rb'
# require '../lib/hotel_front_desk.rb'
# require '../lib/reservation.rb'
# require '../lib/room.rb'
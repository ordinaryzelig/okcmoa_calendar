ENV['TZ'] = 'America/Chicago'

require 'bundler/setup'
Bundler.require :default, :test

require 'minitest/autorun'
require 'minitest/pride'

require 'mocha' # Require AFTER MiniTest.

require './lib/okcmoa'

Dir['./spec/support/**/*.rb'].each { |f| require f }

VCR.configure do |c|
  c.cassette_library_dir = 'spec/support/vcr_cassettes'
  c.hook_into :fakeweb
end

class MiniTest::Spec
  include FixtureHelpers
end

require 'bundler/setup'
Bundler.require

require './lib/crawler'
require './lib/parser'

require './lib/client'

Dir['./util/**/*.rb'].each { |f| require f }
Dir['./lib/models/**/*.rb'].each { |f| require f }

module OKCMOA

  class << self

    def client
      @client ||= Client.new
    end

  end

end

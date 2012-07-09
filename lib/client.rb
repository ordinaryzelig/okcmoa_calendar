require 'google/api_client'

module OKCMOA
  class Client

    attr_reader :api_client
    attr_reader :service

    def initialize
      connect
      @api_client.authorization.fetch_access_token!
      @service = @api_client.discovered_api('calendar', 'v3')
    end

    # Convenience method to list calendars and their ids.
    def calendar_list
      response = @api_client.execute(
        api_method: @service.calendar_list.list,
      )

      response.data.items.each_with_object({}) do |calendar, hash|
        hash[calendar['summary']] = calendar['id']
      end
    end

  private

    def connect
      @api_client = Google::APIClient.new
      @api_client.authorization.client_id       = config['client_id']
      @api_client.authorization.client_secret   = config['client_secret']
      @api_client.authorization.scope           = 'https://www.googleapis.com/auth/calendar?approval_prompt=force'
      @api_client.authorization.refresh_token   = config['refresh_token']
    end

    def config
      @config ||= {
        'client_id'     =>  ENV['GOOGLE_API_CLIENT_ID'],
        'client_secret' =>  ENV['GOOGLE_API_CLIENT_SECRET'],
        'refresh_token' =>  ENV['GOOGLE_API_REFRESH_TOKEN'],
      }
    end

  end
end

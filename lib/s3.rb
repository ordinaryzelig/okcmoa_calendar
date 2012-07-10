require 's3'

module OKCMOA
  class S3

    attr_reader :service
    attr_reader :bucket

    def initialize
      @service = ::S3::Service.new(self.class.service_config)
      @bucket  = service.buckets.find(self.class.bucket_name)
    end

    class << self

      def service_config
        {
          access_key_id: access_key_id,
          secret_access_key: secret_access_key,
        }
      end

      def access_key_id
        ENV['S3_ACCESS_KEY_ID']
      end

      def secret_access_key
        ENV['S3_SECRET_ACCESS_KEY']
      end

      def bucket_name
        'OKCMOA_films'
      end

    end

  end
end

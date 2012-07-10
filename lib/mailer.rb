module OKCMOA
  module Mailer

    class << self

      def mail_exception(ex)
        subject = ex.message
        body    = ex.backtrace.join("\n")
        mail(subject, body)
      end

      def mail(subject, body)
        require 'pony'
        Pony.mail(
          :from => 'okcmoa_calendar@redningja.com',
          :to => 'okcmoa_calendar@redningja.com',
          :subject => subject,
          :body => body,
          :via => :smtp,
          :via_options => {
            :address        => ENV['MAILGUN_SMTP_SERVER'],
            :port           => ENV['MAILGUN_SMTP_PORT'],
            :user_name      => ENV['MAILGUN_SMTP_LOGIN'],
            :password       => ENV['MAILGUN_SMTP_PASSWORD'],
            :authentication => :plain, # :plain, :login, :cram_md5, no auth by default
            :domain         => "okcmoa-calendar.heroku.com" # the HELO domain provided by the client to the server
          }
        )
      end

    end

  end
end

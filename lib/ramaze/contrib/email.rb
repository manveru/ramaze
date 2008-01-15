# EmailHelper can be used as a simple way to send basic e-mails from your app.
#
# Usage:
#
#   require 'ramaze/contrib/email'
#
#   # Set the required traits:
#   Ramaze::EmailHelper.trait[ :smtp_server ] = 'smtp.your-isp.com'
#   Ramaze::EmailHelper.trait[ :smtp_helo_domain ] = "originating-server.com"
#   Ramaze::EmailHelper.trait[ :smtp_username ] = 'username'
#   Ramaze::EmailHelper.trait[ :smtp_password ] = 'password'
#   Ramaze::EmailHelper.trait[ :sender_address ] = 'no-reply@your-domain.com'
#
#   # Optionally, set some other traits:
#   Ramaze::EmailHelper.trait[ :smtp_auth_type ] = :login
#   Ramaze::EmailHelper.trait[ :bcc_addresses ] = [ 'admin@your-domain.com' ]
#   Ramaze::EmailHelper.trait[ :sender_full ] = 'MailBot <no-reply@your-domain.com>'
#   Ramaze::EmailHelper.trait[ :id_generator ] = lambda { "<#{Time.now.to_i}@your-domain.com>" }
#   Ramaze::EmailHelper.trait[ :subject_prefix ] = "[SiteName]"
#
# To send an e-mail:
#
#   Ramaze::EmailHelper.send(
#     "foo@foobarmail.com",
#     "Your fooness",
#     "Hey, you are very fooey!"
#   )

require 'net/smtp'

module Ramaze
  class EmailHelper
    # Required to be set
    trait :smtp_server => 'smtp.your-isp.com'
    trait :smtp_helo_domain => 'your.helo.domain.com'
    trait :smtp_username => 'no-username-set'
    trait :smtp_password => ''
    trait :sender_address => 'no-reply@your-domain.com'

    # Optionally set
    trait :smtp_port => 25
    trait :smtp_auth_type => :login
    trait :bcc_addresses => []
    trait :sender_full => nil
    trait :id_generator => lambda { "<" + Time.now.to_i.to_s + "@" + trait[ :smtp_helo_domain ] + ">" }
    trait :subject_prefix => ""

    class << self
      def send(recipient, subject, message)
        {:recipient => recipient, :subject => subject, :message => message}.each do |k,v|
          raise(ArgumentError, "EmailHelper error: Missing or invalid #{k}: #{v.inspect}")
        end
        sender = trait[:sender_full] || "#{trait[:sender_address]} <#{trait[:sender_address]}>"
        subject = [trait[:subject_prefix], subject].join(' ').strip
        id = trait[:id_generator].call
        email = %{From: #{sender}
To: <#{recipient}>
Date: #{Time.now.rfc2822}
Subject: #{subject}
Message-Id: #{id}

#{message}
}

        send_smtp(email)
      end

      def send_smtp(email, recipient, subject, message)
        options = trait.values_at(:smtp_server, :smtp_port, :smtp_helo_domain,
                                  :smtp_username, :smtp_password, :smtp_auth_type)
        Net::SMTP.start(*options) do |smtp|
          smtp.send_message(email, sender_address, Array[recipient, *bcc_addresses])
          Inform.info "E-mail sent to #{recipient} - '#{subject}'"
        end
      rescue => e
        Inform.error "Failed to send e-mail to #{recipient}"
        Inform.error e
      end
    end
  end
end
# EmailHelper can be used as a simple way to send basic e-mails from your app.
#
# Usage:
#
#   require 'ramaze/contrib/email'
#
#   # Set the required traits:
#   EmailHelper.trait[ :smtp_server ] = 'smtp.your-isp.com'
#   EmailHelper.trait[ :smtp_helo_domain ] = "originating-server.com"
#   EmailHelper.trait[ :smtp_username ] = 'username'
#   EmailHelper.trait[ :smtp_password ] = 'password'
#   EmailHelper.trait[ :sender_address ] = 'no-reply@your-domain.com'
#
#   # Optionally, set some other traits:
#   EmailHelper.trait[ :smtp_auth_type ] = :login
#   EmailHelper.trait[ :bcc_addresses ] = [ 'admin@your-domain.com' ]
#   EmailHelper.trait[ :sender_full ] = 'MailBot <no-reply@your-domain.com>'
#   EmailHelper.trait[ :id_generator ] = lambda { "<#{Time.now.to_i}@your-domain.com>" }
#   EmailHelper.trait[ :subject_prefix ] = "[SiteName]"
#
# To send an e-mail:
#
#   EmailHelper.send(
#     "foo@foobarmail.com",
#     "Your fooness",
#     "Hey, you are very fooey!"
#   )

require 'net/smtp'

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
    
    def EmailHelper.send( recipient, subject, message )
        sender = trait[ :sender_full ] || "#{trait[:sender_address]} <#{trait[:sender_address]}>"
        if recipient
            email = %{From: #{sender}
To: <#{recipient}>
Date: #{Time.now.rfc2822}
Subject: #{ ( trait[ :subject_prefix ] + " " + subject ).strip }
Message-Id: #{trait[ :id_generator ].call}

#{message}
            }
            
            begin
                Net::SMTP.start(
                    trait[ :smtp_server ],
                    trait[ :smtp_port ],
                    trait[ :smtp_helo_domain ],
                    trait[ :smtp_username ],
                    trait[ :smtp_password ],
                    trait[ :smtp_auth_type ]
                ) do |smtp|
                    smtp.send_message(
                        email,
                        trait[ :sender_address ],
                        [ recipient ] + trait[ :bcc_addresses ]
                    )
                    Ramaze::Inform.info "E-mail sent to #{recipient} - '#{subject}'"
                end
            rescue Exception => e
                Ramaze::Inform.error "Failed to send e-mail to #{recipient}: #{e.message}\n" + e.backtrace[ 0..9 ].join( "\n\t" )
            end
        else
            Ramaze::Inform.error "EmailHelper error: Missing or invalid recipient: #{recipient.inspect}.\n" + caller[ 0..9 ].join( "\n\t" )
        end
    end
end

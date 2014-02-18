require 'fission/callback'

=begin
      # In payload: notification_email
      {
        :destination => {
          :email => '',
          :name => ''
        },
        :origin => {
          :email => '',
          :name => ''
        },
        :subject => '',
        :message => '',
        :html => true/false
      }
=end


module Fission
  module Mail
    class Smtp < Fission::Callback

      attr_reader :smtp

      def setup(*args)
        require 'pony'
      end

      def valid?(message)
        super do |payload|
          retrieve(payload, :data, :notification_email)
        end
      end

      def execute(message)
        failure_wrap(message) do |payload|
          deliver(payload)
          job_completed(:mail, payload, message)
        end
      end

      # payload:: Payload
      # Deliver mail notification via smtp based on payload contents
      def deliver(payload)
        config = payload[:data][:notification_email]
        begin
          args = {
            :to => [config[:destination]].flatten(1).map{|d| d[:email]},
            :from => config[:origin][:email],
            :subject => config[:subject],
            :via => :smtp,
            :via_options => config[:via_options] || Carnivore::Config.get(:fission, :mail, :smtp, :via_options) || {}
          }
          if(config[:attachments])
            args[:attachments] = Hash[*config[:attachments].map{|k,v|[k.to_s,v]}.flatten(1)]
          end
          message_key = config[:html] ? :html_body : :body
          args[message_key] = config[:message]
          if(args[:via_options][:authentication])
            args[:via_options][:authentication] = args[:via_options][:authentication].to_s.to_sym
          end
          if(bcc = Carnivore::Config.get(:fission, :mail, :bcc))
            args[:bcc] = bcc
          end
          result = Pony.mail(args)
          debug "Pony delivery result: #{result.inspect}"
        rescue => e
          error "Delivery failed: #{e.class} - #{e}"
          debug "#{e.class}: #{e}\n#{e.backtrace.join("\n")}"
        end
      end

    end
  end
end

Fission.register(:mail, :smtp, Fission::Mail::Smtp)

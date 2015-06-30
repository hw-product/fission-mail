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
    class Mandrill < Fission::Callback

      attr_reader :mandrill

      def setup(*args)
        require 'mandrill'
        @mandrill = ::Mandrill::API.new(
          Carnivore::Config.get(:fission, :mandrill, :api_key)
        )
      end

      def valid?(message)
        super do |payload|
          fission_config[:mandrill][:api_key] &&
            retrieve(payload, :data, :notification_email)
        end
      end

      def execute(message)
        failure_wrap(message) do |payload|
          begin
            deliver(payload)
            payload[:data].delete(:notification_email)
            job_completed(:mail, payload, message)
          rescue Mandrill::Error => e
            error "Delivery failed: #{e.class} - #{e}"
            debug "#{e.class}: #{e}\n#{e.backtrace.join("\n")}"
            failed(payload, message, e.message)
          end
        end
      end

      # payload:: Payload
      # Deliver mail notification via mandrill based on payload contents
      # TODO: Add mime type detection on attachments
      def deliver(payload)
        config = payload[:data][:notification_email]
        begin
          args = {
            :to => [config[:destination]].flatten(1).compact.map{|d| d.merge(:type => :to)},
            :from_email => config[:origin][:email],
            :from_name => config[:origin][:name],
            :subject => config[:subject],
            :attachments => [config[:attachments]].flatten(1).compact.map{|a| {:type => 'text/plain'}.merge(Hash[*a.flatten]) }
          }
          message_key = config[:html] ? :html : :text
          args[message_key] = config[:message]
          if(bcc = Carnivore::Config.get(:fission, :mail, :bcc))
            args[:bcc_address] = bcc
          end
          result = mandrill_send(args)
          debug "Send response payload: #{result.inspect}"
          true
        rescue => e
          error "Failed to send mail: #{e.class} - #{e}"
          debug "#{e.class}: #{e}\n#{e.backtrace.join("\n")}"
          false
        end
      end

      # Keep API call separate for easy test stubbing
      def mandrill_send(args)
        mandrill.messages.send(args, false, 'default')
      end
    end
  end
end

Fission.register(:mail, :mandrill, Fission::Mail::Mandrill)

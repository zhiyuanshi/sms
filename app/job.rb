require 'bundler/setup'

require 'backburner'
require 'twilio-ruby'
require 'faye'
require 'eventmachine'

class Job
  include Backburner::Queue
  queue          "sms"
  queue_priority         0  # most urgent priority is 0
  queue_respond_timeout 15  # number of seconds before job times out

  class << self
    attr_accessor :twilio_config
    attr_accessor :twilio_client
  end

  self.twilio_config = YAML.load_file(File.expand_path("../../config/twilio.yml", __FILE__))
  self.twilio_client = Twilio::REST::Client.new(twilio_config["account_sid"], twilio_config["auth_token"])

  # required
  def self.perform(to, body, endpoint = nil, channel = nil)
    begin
      self.twilio_client.account.messages.create(
        from: self.twilio_config["from"],
        to:   to,
        body: body)
    rescue Twilio::REST::RequestError => e
      $stderr.puts "Rescued exception: #{e}"
    end

    if endpoint && channel
      EM.run do
        client = Faye::Client.new(endpoint)

        publication = client.publish(channel, "status" => "done")

        # http://stackoverflow.com/questions/8572150/faye-ruby-client-is-not-working
        publication.callback { EM.stop_event_loop }
        publication.errback  { |_error| EM.stop_event_loop }
      end
    end
  end
end

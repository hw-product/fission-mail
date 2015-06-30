require 'fission-mail'
require 'pry'

SRC_ADDR = 'foo@example.com'
SRC_NAME = 'Foo'
DST_ADDR = 'bar@example.com'
SUBJECT  = 'test'
BODY     = 'foo'

class Fission::Mail::Mandrill
  attr_accessor :test_payload

  def mandrill_send(args)
    test_payload.set(:args, args)
    Mail::Message.new(args)
  end
end


describe Fission::Mail::Mandrill do

  before do
    @runner = run_setup(:mandrill)
    track_execution(Fission::Mail::Mandrill)
  end

  after do
    @runner.terminate
  end

  let(:actor) { Carnivore::Supervisor.supervisor[:mail] }

  it 'fails to execute if expected paylod or config is missing' do
    Carnivore::Config.set(:fission, :mandrill, :api_key, nil)
    # TODO figure out why we hit an orphan route here / don't get a result back....
    result = transmit_and_wait(actor, payload, 0.5)
    result.must_equal nil
  end

  it 'executes with valid payload' do
    result = transmit_and_wait(actor, payload)
    callback_executed?(result).must_equal true

    arr = [[:to, [{"email"=> DST_ADDR, "type"=>:to}]],
           [:from_email, SRC_ADDR], [:from_name, SRC_NAME],
           [:subject, SUBJECT], [:text, BODY]]
    arr.each { |key, value| result[:args][key].must_equal value }
  end

  it 'clears payload data after execution' do
    result = transmit_and_wait(actor, payload)
    result.get(:data, :notification_email).must_equal nil
  end

  private

  def payload
    h = {
      :notification_email => {
        :destination => {
          :email => DST_ADDR
        },
        :origin => {
          :email => SRC_ADDR,
          :name => SRC_NAME
        },
        :subject => SUBJECT,
        :message => BODY
      }
    }
    Jackal::Utils.new_payload(:test, h)
  end

end

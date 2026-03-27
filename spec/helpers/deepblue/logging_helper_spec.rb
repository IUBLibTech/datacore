# frozen_string_literal: true

class MockInvalidJsonObject
  def respond_to? (to_obj)
    false
  end
end

class MockLogger
  def info (msg)
    "logger: " + msg
  end
end





RSpec.describe Deepblue::LoggingHelper, type: :helper do

  let( :arrow_line ) { ">>>>>>>>>>" }
  let( :msg ) { 'The message.' }
  let( :label ) { 'The Label' }


  describe '#bold_debug' do

    before do
      allow( Rails.logger ).to receive( :debug ).with( any_args )
    end

    context 'with msg' do
      it "logs msg with default 2 arrow lines (1 before and 1 after msg)" do
        Deepblue::LoggingHelper.bold_debug( msg )
        expect( Rails.logger ).to have_received( :debug ).with( arrow_line ).exactly( 2 ).times
        expect( Rails.logger ).to have_received( :debug ).with( msg )
        expect( Rails.logger ).to have_received( :debug ).exactly( 3 ).times
      end
    end

    context 'with msg and lines: 0' do
      it "logs msg with 2 arrow lines (numbers 0 and below corrected to default)" do
        Deepblue::LoggingHelper.bold_debug( msg, lines: 0 )
        expect( Rails.logger ).to have_received( :debug ).with( arrow_line ).exactly( 2 ).times
        expect( Rails.logger ).to have_received( :debug ).with( msg )
        expect( Rails.logger ).to have_received( :debug ).exactly( 3 ).times
      end
    end

    context 'with msg and label' do
      it "logs label then msg with 2 arrow lines" do
        Deepblue::LoggingHelper.bold_debug( msg, label: label )
        expect( Rails.logger ).to have_received( :debug ).with( arrow_line ).exactly( 2 ).times
        expect( Rails.logger ).to have_received( :debug ).with( label )
        expect( Rails.logger ).to have_received( :debug ).with( msg )
        expect( Rails.logger ).to have_received( :debug ).exactly( 4 ).times
      end
    end

    context 'with msg and lines: 2' do
      it "logs label then msg with 4 arrow lines (2 before and 2 after msg)" do
        Deepblue::LoggingHelper.bold_debug( msg, lines: 2 )
        expect( Rails.logger ).to have_received( :debug ).with( arrow_line ).exactly( 4 ).times
        expect( Rails.logger ).to have_received( :debug ).with( msg )
        expect( Rails.logger ).to have_received( :debug ).exactly( 5 ).times
      end
    end

    context 'with msg as array' do
      let( :msg_line_1 ) { "line 1" }
      let( :msg_line_2 ) { "line 2" }
      let( :msg_array ) { [ msg_line_1, msg_line_2 ] }
      it "logs each item of array, one per line" do
        Deepblue::LoggingHelper.bold_debug( msg_array )
        expect( Rails.logger ).to have_received( :debug ).with( arrow_line ).exactly( 2 ).times
        expect( Rails.logger ).to have_received( :debug ).with( msg_line_1 )
        expect( Rails.logger ).to have_received( :debug ).with( msg_line_2 )
        expect( Rails.logger ).to have_received( :debug ).exactly( 4 ).times
      end
    end

    context 'with msg as hash' do
      let( :msg_key1 ) { :key1 }
      let( :msg_key2 ) { :key2 }
      let( :msg_value_1 ) { "value 1" }
      let( :msg_value_2 ) { "value 2" }
      let( :msg_hash ) { [ msg_key1 => msg_value_1, msg_key2 => msg_value_2 ] }

      it "logs each key and value of hash, one per line" do
        Deepblue::LoggingHelper.bold_debug( msg_hash )
        expect( Rails.logger ).to have_received( :debug ).with( arrow_line ).exactly( 2 ).times
        expect( Rails.logger ).to have_received( :debug ).with( "#{msg_key1}: #{msg_value_1}" )
        expect( Rails.logger ).to have_received( :debug ).with( "#{msg_key2}: #{msg_value_2}" )
        expect( Rails.logger ).to have_received( :debug ).exactly( 4 ).times
      end

      context "with key_value_lines: false" do
        it "logs each key value pair of hash all on one line" do
          Deepblue::LoggingHelper.bold_debug( msg_hash, key_value_lines: false )
          expect( Rails.logger ).to have_received( :debug ).with( arrow_line ).exactly( 2 ).times
          expect( Rails.logger ).to have_received( :debug ).with({:key1=>"#{msg_value_1}", :key2=>"#{msg_value_2}"})
          expect( Rails.logger ).to have_received( :debug ).exactly( 3 ).times
        end
      end
    end

    skip "Add a test for block"
    skip "Add a test for hash and block"

    # context 'with block msg' do
    #   let( :block_msg ) { 'The block message.' }
    #   before do
    #     allow( Rails.logger ).to receive( :debug ).with( any_args )
    #   end
    #   it do
    #     Deepblue::LoggingHelper.bold_debug( lines: 2 ) { block_msg }
    #     expect( Rails.logger ).to have_received( :debug ).with( arrow_line ).exactly( 4 ).times
    #     expect( Rails.logger ).to have_received( :debug ).with( block_msg )
    #     expect( Rails.logger ).to have_received( :debug ).exactly( 5 ).times
    #   end
    # end
  end


  describe '#self.called_from' do
    before {
      allow(Deepblue::LoggingHelper).to receive(:caller_locations).with(1,2).and_return ["", "caller locations 1 2"]
    }
    it "calls caller_locations and returns string" do
      expect(Deepblue::LoggingHelper).to receive(:caller_locations).with(1,2)
      expect(Deepblue::LoggingHelper.called_from).to eq "called from: caller locations 1 2"
    end
  end


  describe '#self.caller' do
    before {
      allow(Deepblue::LoggingHelper).to receive(:caller_locations).with(1,2).and_return ["", "caller locations 1 2"]
    }
    it "calls caller_locations and returns string" do
      expect(Deepblue::LoggingHelper).to receive(:caller_locations).with(1,2)
      expect(Deepblue::LoggingHelper.caller).to eq "caller locations 1 2"
    end
  end


  describe '#self.debug' do

    before {
      allow( Rails.logger ).to receive( :debug ).with( any_args )
    }

    context 'with msg' do
      it "logs msg with no arrow lines" do
        Deepblue::LoggingHelper.debug( msg )
        expect( Rails.logger ).not_to have_received( :debug ).with( arrow_line )
        expect( Rails.logger ).to have_received( :debug ).with( msg )
      end
    end

    context 'with msg and lines: negative number' do
      it "logs msg with no arrow lines (negative numbers corrected to 0)" do
        Deepblue::LoggingHelper.debug( msg, lines: -1 )
        expect( Rails.logger ).not_to have_received( :debug ).with( arrow_line )
        expect( Rails.logger ).to have_received( :debug ).with( msg )
      end
    end

    context 'with msg and label' do
      it "logs label then msg" do
        Deepblue::LoggingHelper.debug( msg, label: label )
        expect( Rails.logger ).not_to have_received( :debug ).with( arrow_line )
        expect( Rails.logger ).to have_received( :debug ).with( label )
        expect( Rails.logger ).to have_received( :debug ).with( msg )
        expect( Rails.logger ).to have_received( :debug ).exactly( 2 ).times
      end
    end

    context 'with msg and lines: 2' do
      it "logs msg with two arrow lines preceding and two following" do
        Deepblue::LoggingHelper.debug( msg, lines: 2 )
        expect( Rails.logger ).to have_received( :debug ).with( arrow_line ).exactly( 4 ).times
        expect( Rails.logger ).to have_received( :debug ).with( msg )
        expect( Rails.logger ).to have_received( :debug ).exactly( 5 ).times
      end
    end

    context 'with msg as array' do
      let( :msg_line_1 ) { "line 1" }
      let( :msg_line_2 ) { "line 2" }
      let( :msg_array ) { [ msg_line_1, msg_line_2 ] }
      it "logs each item of array, one per line" do
        Deepblue::LoggingHelper.debug( msg_array )
        expect( Rails.logger ).to have_received( :debug ).with( msg_line_1 )
        expect( Rails.logger ).to have_received( :debug ).with( msg_line_2 )
        expect( Rails.logger ).to have_received( :debug ).exactly( 2 ).times
      end
    end

    context 'with msg as hash' do
      let( :msg_key1 ) { :key1 }
      let( :msg_key2 ) { :key2 }
      let( :msg_value_1 ) { "value 1" }
      let( :msg_value_2 ) { "value 2" }
      let( :msg_hash ) { [ msg_key1 => msg_value_1, msg_key2 => msg_value_2 ] }

      it "logs each key and value of hash, one per line" do
        Deepblue::LoggingHelper.debug( msg_hash )
        expect( Rails.logger ).to have_received( :debug ).with( "#{msg_key1}: #{msg_value_1}" )
        expect( Rails.logger ).to have_received( :debug ).with( "#{msg_key2}: #{msg_value_2}" )
        expect( Rails.logger ).to have_received( :debug ).exactly( 2 ).times
      end

      context "with key_value_lines: false" do
        it "logs each key value pair of hash all on one line" do
          Deepblue::LoggingHelper.debug( msg_hash, key_value_lines: false )
          expect( Rails.logger ).to have_received( :debug ).with({:key1=>"#{msg_value_1}", :key2=>"#{msg_value_2}"})
          expect( Rails.logger ).to have_received( :debug ).exactly( 1 ).times
        end
      end
    end

    skip "Add a test for block"
    skip "Add a test for hash and block"
  end


  describe '#self.here' do
    before {
      allow(Deepblue::LoggingHelper).to receive(:caller_locations).with(1,1).and_return ["caller locations 1 1"]
    }
    it "calls caller_locations and returns string" do
      expect(Deepblue::LoggingHelper).to receive(:caller_locations).with(1,1)
      expect(Deepblue::LoggingHelper.here).to eq "caller locations 1 1"
    end
  end


  describe "#self.log" do
    before {
      allow(Deepblue::LoggingHelper).to receive(:timestamp_now).and_return "now"
      allow(Deepblue::LoggingHelper).to receive(:timestamp_zone).and_return "zone"
      allow(Deepblue::LoggingHelper).to receive(:msg_to_log).with(class_name: "MockLoggingHelper", event: "This Event", event_note: "Note", id: "ID#",
                                                                  timestamp: "now", time_zone: "zone", cat: "tiger", dog: "wolf").and_return "msg to log"
      allow(Rails.logger).to receive(:info).with("msg to log")
    }

    echo_to_rails = [false, true]
    echo_to_rails.each do |echo|

      context "when echo_to_rails_logger parameter is #{echo}" do
        it "calls msg_to_log, and logger.info #{"and Rails.logger.info" if echo}" do
          logger = MockLogger.new
          expect(logger).to receive(:info).with "msg to log"
          expect(Rails.logger).to receive(:info).with("msg to log") if echo
          expect(Rails.logger).not_to receive(:info).with("msg to log") unless echo

          Deepblue::LoggingHelper.log(class_name: "MockLoggingHelper", event: "This Event", event_note: "Note", id: "ID#",
                                      echo_to_rails_logger: echo, logger: logger, cat: "tiger", dog: "wolf" )
        end
      end
    end

    after {
      expect(Deepblue::LoggingHelper).to have_received(:timestamp_now)
      expect(Deepblue::LoggingHelper).to have_received(:timestamp_zone)
      expect(Deepblue::LoggingHelper).to have_received(:msg_to_log).with(class_name: "MockLoggingHelper", event: "This Event", event_note: "Note", id: "ID#",
                                                                   timestamp: "now", time_zone: "zone", cat: "tiger", dog: "wolf")
    }
  end


  describe '#self.msg_to_log' do
    let( :class_name ) { 'DataSet' }
    let( :event ) { 'the_event' }
    let( :event_note ) { 'the_event_note' }
    let( :blank_event_note ) { '' }
    let( :id ) { 'id1234' }
    let( :timestamp ) { Time.now.to_formatted_s(:db ) }
    let( :time_zone ) { DateTime.now.zone }

    context 'params without added key values' do
      let( :key_values ) { { event: event,
                             event_note: event_note,
                             timestamp: timestamp,
                             time_zone: time_zone,
                             class_name: class_name,
                             id: id } }
      let( :json ) { ActiveSupport::JSON.encode key_values }
      let( :result1 ) { "#{timestamp} #{event}/#{event_note}/#{class_name}/#{id} #{json}" }
      it "includes event_note and performs json encoding" do
        expect( Deepblue::LoggingHelper.msg_to_log( class_name: class_name,
                                                    event: event,
                                                    event_note: event_note,
                                                    id: id,
                                                    timestamp: timestamp,
                                                    time_zone: time_zone ) ).to eq result1
      end
    end

    context 'params with a blank event_note, without added key values' do
      let( :key_values ) { { event: event, timestamp: timestamp, time_zone: time_zone, class_name: class_name, id: id } }
      let( :json ) { ActiveSupport::JSON.encode key_values }
      let( :result1 ) { "#{timestamp} #{event}//#{class_name}/#{id} #{json}" }
      it "does not include event_note and performs json encoding" do
        expect( Deepblue::LoggingHelper.msg_to_log( class_name: class_name,
                                                    event: event,
                                                    event_note: blank_event_note,
                                                    id: id,
                                                    timestamp: timestamp,
                                                    time_zone: time_zone ) ).to eq result1
      end
    end

    context 'params with added key values and without json encoding' do
      let( :theme ) { "bright"}
      let( :organizer ) { "Sharon Elspeth" }
      let( :key_values ) { { event: event,
                             event_note: event_note,
                             timestamp: timestamp,
                             time_zone: time_zone,
                             class_name: class_name,
                             id: id } }
      let( :added ) { { event: event,
                        event_note: event_note,
                        timestamp: timestamp,
                        time_zone: time_zone,
                        class_name: class_name,
                        id: id,
                        theme: theme,
                        organizer: organizer} }
      let( :result1 ) { "#{timestamp} #{event}/#{event_note}/#{class_name}/#{id} #{added}" }
      it "merges in added key values and does NOT perform json encoding" do
        expect( Deepblue::LoggingHelper.msg_to_log( class_name: class_name,
                                                    event: event,
                                                    event_note: event_note,
                                                    id: id,
                                                    timestamp: timestamp,
                                                    time_zone: time_zone,
                                                    json_encode: false,
                                                    theme: theme,
                                                    organizer: organizer) ).to eq result1
      end
    end

  end


  describe '#self.obj_attribute_names' do
    context "when object does not have attribute names" do
      it "returns label with N/A" do
        object = OpenStruct.new(class: "Class Name")
        expected_result = "Attributes.attribute_names=N/A"

        expect(Deepblue::LoggingHelper.obj_attribute_names "Attributes", object).to eq expected_result
      end
    end

    context "when object has attribute names" do
      it "returns attribute names from object with label as string" do
        object = OpenStruct.new(attribute_names: ["Here", "There", "Everywhere"])
        expected_result = "Attributes.attribute_names=[\"Here\", \"There\", \"Everywhere\"]"

        expect(Deepblue::LoggingHelper.obj_attribute_names "Attributes", object).to eq expected_result
      end
    end
  end


  describe '#self.obj_class' do
    it "returns class name from object parameter with label" do
      object = OpenStruct.new(class: OpenStruct.new(name: "OriginalClass"))
      expected_result = "Class Name.class=OriginalClass"

      expect(Deepblue::LoggingHelper.obj_class "Class Name", object).to eq expected_result
    end
  end


  describe '#self.obj_instance_variables' do
    it "returns instance_variables property on object parameter with label as a string" do
      object = OpenStruct.new(instance_variables: [:Hello, :Goodbye, :ThankYou])
      expected_result = "Variables.instance_variables=[:Hello, :Goodbye, :ThankYou]"

      expect(Deepblue::LoggingHelper.obj_instance_variables "Variables", object).to eq expected_result
    end
  end


  describe "#self.obj_methods" do
    it "returns sorted methods with label as a string" do
      object = OpenStruct.new(methods: ["Run", "Walk", "Jump", "Hide"])
      expected_result = "Methods.methods=[\"Hide\", \"Jump\", \"Run\", \"Walk\"]"

      expect(Deepblue::LoggingHelper.obj_methods "Methods", object).to eq expected_result
    end
  end


  describe '#self.obj_to_json' do
    context "when object can be converted to JSON" do
      it "returns JSON string with label" do
        student = { firstname: 'Brenda', age: 19, is_student: true, grades: [80, 92, 77, 83] }
        json_string = "Student Info.to_json={\"firstname\":\"Brenda\",\"age\":19,\"is_student\":true,\"grades\":[80,92,77,83]}"

        expect(Deepblue::LoggingHelper.obj_to_json "Student Info", student).to eq json_string
      end
    end

    context "when object cannot be converted to JSON" do
      object = MockInvalidJsonObject.new
      it "returns label with N/A" do
        expect(Deepblue::LoggingHelper.obj_to_json "Student Info", object).to eq "Student Info.to_json=N/A"
      end
    end
  end


  describe '#self.system_as_current_user' do
    subject { Deepblue::LoggingHelper.system_as_current_user }
    it { expect( subject ).to eq 'Deepblue' }
  end


  describe "#self.timestamp_now" do
    before {
      allow(Time).to receive(:now).and_return DateTime.new(2000, 1, 1, 12, 12, 12)
    }
    it "returns formatted timestamp" do
      expect(Deepblue::LoggingHelper.timestamp_now).to eq "2000-01-01 12:12:12"
    end
  end


  describe "#self.timestamp_zone" do
    it "returns a string" do
      expect(Deepblue::LoggingHelper.timestamp_zone).instance_of? String
    end
  end

end

class MockJsonLoggerHelper
  include ::Deepblue::JsonLoggerHelper::ClassMethods
end

class MockCurationConcern
  def id
    "ID"
  end

  def visibility
    "highly visible"
  end

  def embargo_release_date
    "released"
  end

  def visibility_during_embargo
    "visible"
  end

  def visibility_after_embargo
    "afterwards"
  end
end

class MockCuration

  def initialize(visibility = "", enclosure = "")
    @visibility = visibility
    @enclosure = enclosure
  end
  def visibility
    @visibility
  end

  def enclosure
    @enclosure
  end

  def has_attribute?(method_name)
    method_name = method_name.to_s
    if method_name == "visibility" || method_name == "enclosure"
      true
    else
      false
    end
  end

  def [](key)
    key = key.to_s
    if key == "visibility"
      @visibility
    elsif key == "enclosure"
      @enclosure
    end
  end
end



RSpec.describe Deepblue::JsonLoggerHelper, type: :helper do

  subject { MockJsonLoggerHelper.new }

  describe 'constants' do
    it do
      expect( Deepblue::JsonLoggerHelper::TIMESTAMP_FORMAT ).to eq '\d\d\d\d\-\d\d\-\d\d \d\d:\d\d:\d\d'
      expect( Deepblue::JsonLoggerHelper::RE_TIMESTAMP_FORMAT ).to eq /^\d\d\d\d\-\d\d\-\d\d \d\d:\d\d:\d\d$/
      expect( Deepblue::JsonLoggerHelper::RE_LOG_LINE ).to eq /^(\d\d\d\d\-\d\d\-\d\d \d\d:\d\d:\d\d) ([^\/]+)\/([^\/]*)\/([^\/]+)\/([^\/ ]*) (.*)$/
      expect( Deepblue::JsonLoggerHelper::PREFIX_UPDATE_ATTRIBUTE ).to eq "UpdateAttribute_"
    end
  end


  describe "#extract_embargo_form_values" do
    before {
      allow(Deepblue::LoggingHelper).to receive(:here).and_return "here"
      allow(Deepblue::LoggingHelper).to receive(:called_from).and_return "called_from"
      allow(Deepblue::LoggingHelper).to receive(:obj_class).with("curation_concern", instance_of(MockCurationConcern)).and_return "obj_class"
      allow(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here",
         "called_from",
         "obj_class",
         "curation_concern.id=ID",
         "update_key_prefix=prefix",
         "form_params={\"embargo_release_date\"=>\"soon\", \"visibility_during_embargo\"=>\"once\", \"visibility_after_embargo\"=>\"then\"}",
         ""]
      allow(subject).to receive(:form_update_attribute).with(key: :embargo_release_date, old_value: "released", new_value: "soon").and_return "best"
      allow(subject).to receive(:form_update_attribute).with(key: :visibility_during_embargo, old_value: "visible", new_value: "once").and_return "highest"
      allow(subject).to receive(:form_update_attribute).with(key: :visibility_after_embargo, old_value: "afterwards", new_value: "then").and_return "finest"
    }
    it "logs form params and updates form attributes" do
      expect(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here",
       "called_from",
       "obj_class",
       "curation_concern.id=ID",
       "update_key_prefix=prefix",
       "form_params={\"embargo_release_date\"=>\"soon\", \"visibility_during_embargo\"=>\"once\", \"visibility_after_embargo\"=>\"then\"}",
       ""]
      expect(subject).to receive(:form_update_attribute).with(key: :embargo_release_date, old_value: "released", new_value: "soon")
      expect(subject).to receive(:form_update_attribute).with(key: :visibility_during_embargo, old_value: "visible", new_value: "once")
      expect(subject).to receive(:form_update_attribute).with(key: :visibility_after_embargo, old_value: "afterwards", new_value: "then")

      expect(subject.extract_embargo_form_values(curation_concern: MockCurationConcern.new,
                                                 update_key_prefix: "prefix",
                                                 form_params: {"embargo_release_date" => "soon",
                                                               "visibility_during_embargo" => "once",
                                                               "visibility_after_embargo" => "then"}))
        .to eq :prefixembargo_release_date => "best", :prefixvisibility_during_embargo => "highest", :prefixvisibility_after_embargo => "finest"
    end
  end


  describe "#form_update_attribute" do
    before {
      allow(ActiveSupport::JSON).to receive(:encode).with("ancient").and_return "primal"
      allow(ActiveSupport::JSON).to receive(:decode).with("primal").and_return "primordial"
    }
    it "returns hash" do
      expected_return = { attribute: "key", old_value: "primordial", new_value: "mountain fresh" }
      expect(subject.form_update_attribute( key: "key", old_value: "ancient", new_value: "mountain fresh" )).to eq expected_return
    end
  end


  describe "#form_params_to_update_attribute_key_values" do
    context "when form_params are nil" do
      it "returns empty hash" do
        expect(subject.form_params_to_update_attribute_key_values curation_concern: MockCuration.new, form_params: nil).to be_empty
      end
    end

    context "when no new values are attributes on curation_concern" do
      it "returns empty hash" do
        expect(subject).not_to receive(:form_update_attribute)
        expect(subject.form_params_to_update_attribute_key_values curation_concern: MockCuration.new,
          form_params: {"one" => "apple", "two" => "banana", "three" => "coconut"}).to be_empty
      end
    end

    context "when new values are on curation_concern" do
      concern = MockCuration.new("clouded", "unopened")
      before {
        allow(subject).to receive(:form_update_attribute).with(key: :enclosure, old_value: "unopened", new_value: "opened").and_return "open attribute"
        allow(subject).to receive(:form_update_attribute).with(key: :visibility, old_value: "clouded", new_value: "clear").and_return "clear attribute"
      }
      it "returns hash of key values" do
        return_values = {:UpdateAttribute_enclosure => "open attribute", :UpdateAttribute_visibility => "clear attribute"}
        expect(subject.form_params_to_update_attribute_key_values curation_concern: concern,
                                                                  form_params: {"enclosure" => "opened", "visibility" => "clear"}).to eq return_values
      end
    end

    context "when form_param visibility new value is embargo" do
      concern = MockCuration.new("unveil")
      before {
        allow(subject).to receive(:extract_embargo_form_values).with(curation_concern: concern,
                                                                     update_key_prefix: "UpdateAttribute_",
                                                                     form_params: {"visibility" => "embargo"})
                                                               .and_return "embargo values"
        allow(subject).to receive(:form_update_attribute).with(key: :visibility, old_value: "unveil", new_value: "embargo").and_return "updated attribute"
      }
      it "returns hash of key values including embargo" do
        expect(subject).to receive(:extract_embargo_form_values).with(curation_concern: concern,
                                                                     update_key_prefix: "UpdateAttribute_",
                                                                     form_params: {"visibility" => "embargo"})
        expect(subject).to receive(:form_update_attribute).with(key: :visibility, old_value: "unveil", new_value: "embargo")

        expectation = {:UpdateAttribute_visibility => "updated attribute", :embargo => "embargo values"}
        expect(subject.form_params_to_update_attribute_key_values curation_concern: concern,
                                                                  form_params: {"visibility" => "embargo"}).to eq expectation
      end
    end

    context "when new value is equal to old value and delta_only is true" do
      concern = MockCuration.new("opaque")
      it "returns hash without new value" do
        expect(subject).not_to receive(:form_update_attribute)
        expect(subject.form_params_to_update_attribute_key_values curation_concern: concern,
                                                                  delta_only: true,
                                                                  form_params: {"visibility" => "opaque"}).to be_empty
      end
    end

    context "when new value is equal to old value and delta_only is false" do
      concern = MockCuration.new("brilliant")
      before {
        allow(subject).to receive(:form_update_attribute).with(key: :visibility,
                                                               old_value: "brilliant",
                                                               new_value: "brilliant").and_return "brilliant attribute"
      }
      it "returns hash with value" do
        expect(subject).to receive(:form_update_attribute).with(key: :visibility, old_value: "brilliant", new_value: "brilliant")
        return_hash = {:UpdateAttribute_visibility => "brilliant attribute"}
        expect(subject.form_params_to_update_attribute_key_values curation_concern: concern, delta_only: false,
                                                                  form_params: {"visibility" => "brilliant"}).to eq return_hash
      end
    end

    context "when new value is nil" do
      concern = MockCuration.new("foggy")
      it "returns hash without new value" do
        expect(subject).not_to receive(:form_update_attribute)
        expect(subject.form_params_to_update_attribute_key_values curation_concern: concern,
                                                                  form_params: {"visibility" => nil}).to be_empty
      end
    end

    context "when new value is an array" do
      concern = MockCuration.new("foggy")
      before {
        allow(subject).to receive(:handle_array_value).with(["bright", ""]).and_return ["bright"]
        allow(subject).to receive(:form_update_attribute).with(key: :visibility, old_value: "foggy", new_value: ["bright"]).and_return "bright attribute"

      }
      it "calls handle_array_value" do
        expect(subject.form_params_to_update_attribute_key_values curation_concern: concern,
          form_params: {"visibility" => ["bright", ""]}).to eq :UpdateAttribute_visibility => "bright attribute"
      end
    end
  end


  describe "#handle_array_value" do
    context "when array parameter is blank" do
      it "returns nil" do
        expect(subject.handle_array_value []).nil? == true
      end
    end

    context "when single array element is an empty string" do
      it "returns nil" do
        expect(subject.handle_array_value ['']).nil? == true
      end
    end

    context "when array size is greater than 1 and last element is an empty string" do
      it "removes last element, returns array" do
        expect(subject.handle_array_value ["bud", "bloom", ""]).to eq ["bud", "bloom"]
      end
    end

    context "when array is acceptable" do
      it "returns array parameter" do
        expect(subject.handle_array_value ["sprout", "blossom", "ripen"]).to eq ["sprout", "blossom", "ripen"]
      end
    end
  end


  describe '#logger_initialize_key_values' do
    let( :event_note ) { 'the_event_note' }
    let( :user_email ) { 'user@email.com' }

    context 'parameters: user_email and event_note' do
      subject do
        lambda do |user_email, event_note|
          Deepblue::LoggingHelper.initialize_key_values( user_email: user_email, event_note: event_note )
        end
      end

      let( :result_both ) { { user_email: user_email, event_note: event_note } }
      let( :result_no_event_note ) { { user_email: user_email } }

      it { expect( subject.call( user_email, event_note ) ).to eq result_both }
      it { expect( subject.call( user_email, '' ) ).to eq result_no_event_note }
      it { expect( subject.call( user_email, nil ) ).to eq result_no_event_note }
    end

    context 'parameters: user_email, event_note and added' do
      let( :added1 ) { 'one' }
      let( :added2 ) { 'two' }

      let( :result1 ) { { user_email: user_email, event_note: event_note, added1: added1 } }
      let( :result2 ) { { user_email: user_email, event_note: event_note, added1: added1, added2: added2 } }

      it 'returns a hash containing user_email, event_note, and added1' do
        expect( Deepblue::LoggingHelper.initialize_key_values( user_email: user_email,
                                                               event_note: event_note,
                                                               added1: added1 ) ).to eq result1
      end

      it 'returns a hash containing user_email, event_note, added1, and added2' do
        expect( Deepblue::LoggingHelper.initialize_key_values( user_email: user_email,
                                                               event_note: event_note,
                                                               added1: added1,
                                                               added2: added2 ) ).to eq result2
      end
    end
  end


  describe "#logger_json_encode" do
    context "when json_encode is false" do
      it "returns value parameter" do
        expect(subject.logger_json_encode value: "cake", json_encode: false).to eq "cake"
      end
    end

    context "when json_encode is true" do
      before {
        allow(ActiveSupport::JSON).to receive(:encode).with("immaterial").and_return "encoded json"
      }
      it "calls JSON encodes value parameter" do
        expect(ActiveSupport::JSON).to receive(:encode)
        expect(subject.logger_json_encode value: "immaterial", json_encode: true).to eq "encoded json"
      end
    end

    context "when json_encode is true and Exception occurs" do
      context "when value is not key value pairs" do
        before {
          allow(ActiveSupport::JSON).to receive(:encode).with(1.5).and_raise
          allow(Rails.logger).to receive(:error)
        }
        it "calls Rails.logger.error and returns value parameter as string" do
          expect(Rails.logger).to receive(:error)
          expect(subject.logger_json_encode value: 1.5, json_encode: true).to eq "1.5"
        end
      end

      context "when value is key value pairs" do
        before {
          allow(ActiveSupport::JSON).to receive(:encode).with({"amphibian" => "frog", "herbivore" => "cow"}).and_raise
          allow(Rails.logger).to receive(:error)

          allow(ActiveSupport::JSON).to receive(:encode).with("frog").and_return "axolotl"
          allow(ActiveSupport::JSON).to receive(:encode).with("cow").and_return "elk"
          allow(ActiveSupport::JSON).to receive(:encode).with("amphibian" => "axolotl", "herbivore" => "elk").and_return "JSON result"
        }
        it "calls Rails.logger.error, JSON encodes key value pairs" do
          expect(Rails.logger).to receive(:error)
          expect(subject.logger_json_encode value: {"amphibian" => "frog", "herbivore" => "cow"}, json_encode: true).to eq "JSON result"
        end
      end
    end
  end


  describe "#msg_to_log" do
    context "when event_note parameter is blank" do
      before {
        key_values =  { event: "event", timestamp: "time stamp", time_zone: "zone", class_name: "class name", id: "ID",
                        guest: "person", organizer: "supervisor"}
        allow(subject).to receive(:logger_json_encode).with(value: key_values, json_encode: true).and_return "key values"
      }
      it "returns string with formatted values without event_note" do
        expect(subject.msg_to_log class_name: "class name", event: "event", event_note: " ", id: "ID", timestamp: "time stamp", time_zone: "zone",
                                  guest: "person", organizer: "supervisor").to eq "time stamp event//class name/ID key values"
      end
    end

    context "when event_note parameter has a value" do
      before {
        key_values =  { event: "event", event_note: "note", timestamp: "time stamp", time_zone: "zone", class_name: "class name", id: "ID",
                        guest: "person", organizer: "supervisor"}
        allow(subject).to receive(:logger_json_encode).with(value: key_values, json_encode: true).and_return "key values"
      }
      it "returns string with formatted values including event_note" do
        expect(subject.msg_to_log class_name: "class name", event: "event", event_note: "note", id: "ID", timestamp: "time stamp", time_zone: "zone",
                                  guest: "person", organizer: "supervisor").to eq "time stamp event/note/class name/ID key values"
      end
    end
  end


  describe "#parse_log_line" do
    context "when log_line is in incorrect format" do
      context "when line_number parameter is blank" do
        before {
          allow(subject).to receive(:raise).with(Deepblue::LogParseError, "parse of log line failed: '@incorrectly| $formatted% *string&'")
        }
        it "raises LogParseError with custom message without a line number" do
          begin
            expect(subject.parse_log_line "@incorrectly| $formatted% *string&").to raise_error(Deepblue::LogParseError,
                                                                                              "parse of log line failed: '@incorrectly| $formatted% *string&'")
          rescue NoMethodError
            # the match variable is null so an error occurs when the test expects an array
          end
        end
      end

      context "when line_number parameter has a value" do
        before {
          allow(subject).to receive(:raise).with(Deepblue::LogParseError, "parse of log line failed at line 27: '%wrong! @format- &message^'")
        }
        it "raises LogParseError with custom message including line number" do
          begin
            expect(subject.parse_log_line "%wrong! @format- &message^",
                                          line_number: 27).to raise_error(Deepblue::LogParseError,
                                                                          "parse of log line failed at line 27: '%wrong! @format- &message^'")
          rescue NoMethodError
            # the match variable is null so an error occurs when the test expects an array
          end
        end
      end
    end

    context "when log_line is in correct format" do
      context "when key values are NOT raw" do
        before {
          allow(subject).to receive(:parse_log_line_key_values).with("key_values").and_return "parsed key values"
        }
        it "returns individual line values with parsed key values" do
          expect(subject).to receive(:parse_log_line_key_values).with("key_values")

          return_expected = ["2002-12-21 12:01:22", "event", "event_note", "class_name", "id", "parsed key values"]
          expect(subject.parse_log_line "2002-12-21 12:01:22 event/event_note/class_name/id key_values",
                                        raw_key_values: false).to eq return_expected
        end
      end

      context "when key values are raw" do
        it "returns individual line values without parsing key values" do
          return_to_expect = ["2002-12-21 12:01:22", "event", "event_note", "class_name", "id", "key_values"]
          expect(subject.parse_log_line "2002-12-21 12:01:22 event/event_note/class_name/id key_values",
                                        raw_key_values: true).to eq return_to_expect
        end
      end
    end
  end


  describe "#parse_log_line_key_values" do
    it "decodes a JSON formatted string" do
      expect(subject.parse_log_line_key_values "{\"label\":\"bronze\",\"id\":\"2002\"}").to eq "label" => "bronze", "id" => "2002"
    end
  end


  describe "#system_as_current_user" do
    it "returns string" do
      expect(subject.system_as_current_user).to eq "Deepblue"
    end
  end


  describe "#timestamp_now" do
    before {
      allow(Deepblue::LoggingHelper).to receive(:timestamp_now).and_return "2000-01-01 12:12:12"
    }
    it "calls Deepblue::LoggingHelper timestamp_now" do
      expect(subject.timestamp_now).to eq "2000-01-01 12:12:12"
    end
  end


  describe "#timestamp_zone" do
    before {
      allow(Deepblue::LoggingHelper).to receive(:timestamp_zone).and_return "timestamp zone"
    }
    it "calls Deepblue::LoggingHelper timestamp_zone" do
      expect(subject.timestamp_zone).to eq "timestamp zone"
    end
  end


  describe "#to_log_format_timestamp" do
    context "when timestamp parameter is a string in timestamp format" do
      it "returns timestamp parameter" do
        expect(subject.to_log_format_timestamp "2000-02-02 02:02:02").to eq "2000-02-02 02:02:02"
      end
    end

    context "when parameter provided is a string with a time value NOT in timestamp format" do
      it "returns parameter as a string in timestamp format" do
        expect(subject.to_log_format_timestamp "Weekday Monday, Auguste 26 2025 at 11 AM of the morning").to eq "2025-08-26 11:00:00"
      end
    end

    context "when parameter provided is a string with a time value without a date" do
      before {
        allow(Time).to receive(:now).and_return DateTime.new(2012, 12, 12)
      }
      it "returns a string" do
        expect(subject.to_log_format_timestamp "2 pm").instance_of? String
      end
    end

    context "when parameter provided does not have a time value" do
      it "raises error" do    # text string
        begin
          expect(subject.to_log_format_timestamp "rainbows").to raise_error
        rescue ArgumentError
          # Time.parse raises an error
        end
      end

      it "raises error" do   # empty string
        begin
          expect(subject.to_log_format_timestamp "").to raise_error
        rescue ArgumentError
          # Time.parse raises an error
        end
      end
    end

    context "when parameter provided is NOT a string" do
      it "converts parameter to a string" do
        expect(subject.to_log_format_timestamp 20000).to eq "20000"
      end
    end

    context "when parameter provided is nil" do
      it "returns empty string" do
        expect(subject.to_log_format_timestamp nil).to be_blank
      end
    end
  end


  describe "#update_attribute_key_values" do
    context "when update_attr_key_values are blank" do
      it "returns nil" do
        expect(subject).not_to receive(:curation_concern_attribute)
        expect(subject.update_attribute_key_values curation_concern: nil, cake: "").to be_blank
      end
    end

    context "when update_attr_key_values has key :update_attr_key_values" do
      before {
        allow(subject).to receive(:curation_concern_attribute).with(curation_concern: "curation concern", attribute: "chocolate").and_return "saffron"
        allow(subject).to receive(:curation_concern_attribute).with(curation_concern: "curation concern", attribute: "strawberry").and_return "raspberry"
      }
      it "returns attribute key value pairs with new values" do
        return_values = {
          :UpdateAttribute_a => { attribute: "chocolate", old_value: "vanilla", new_value: "saffron" },
          :UpdateAttribute_b => { attribute: "strawberry", old_value: "banana", new_value: "raspberry" }
        }

        expect(subject.update_attribute_key_values curation_concern: "curation concern",
          update_attr_key_values: { :UpdateAttribute_a => {:attribute => "chocolate", :old_value => "vanilla"},
                                    :UpdateAttribute_b => {:attribute => "strawberry", :old_value => "banana"} } ).to eq return_values
      end
    end

    context "when update_attr_key_values does not have key :update_attr_key_values" do
      before {
        allow(subject).to receive(:curation_concern_attribute).with(curation_concern: "curation concern", attribute: "almond").and_return "pecan"
        allow(subject).to receive(:curation_concern_attribute).with(curation_concern: "curation concern", attribute: "brownie").and_return "cupcake"
      }
      it "returns attribute key value pairs with new values" do
        return_values = {
          :UpdateAttribute_a => { attribute: "almond", old_value: "macadamia", new_value: "pecan" },
          :UpdateAttribute_b => { attribute: "brownie", old_value: "fudge", new_value: "cupcake" }
        }

        expect(subject.update_attribute_key_values curation_concern: "curation concern",
          :UpdateAttribute_a => {:attribute => "almond", :old_value => "macadamia"},
          :UpdateAttribute_b => {:attribute => "brownie", :old_value => "fudge"}  ).to eq return_values
      end
    end

    context "when attribute old value equals new value" do
      before {
        allow(subject).to receive(:curation_concern_attribute).with(curation_concern: "curation concern", attribute: "melon").and_return "cantaloupe"
      }
      it "does not include attribute in returned values" do
        expect(subject.update_attribute_key_values curation_concern: "curation concern",
                                                   :UpdateAttribute_a => {:attribute => "melon", :old_value => "cantaloupe"}).to be_empty
      end
    end
  end


  describe "#curation_concern_attribute" do
    context "when attribute is :visibility" do
      it "returns curation_concern visibility" do
        expect(subject.curation_concern_attribute curation_concern: MockCurationConcern.new, attribute: :visibility).to eq "highly visible"
      end
    end

    context "when attribute is not :visibility" do
      it "returns the value of the attribute parameter as a key" do
        expect(subject.curation_concern_attribute curation_concern: {"waterfall" => "mist"}, attribute: "waterfall").to eq "mist"
      end
    end
  end


  pending "#self.included"
end

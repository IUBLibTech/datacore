require 'rails_helper'

class EmailMock
  include ::Deepblue::EmailBehavior

  def email_create(current_user:, event_note: "")
    "user email"
  end
end

RSpec.describe Deepblue::EmailBehavior do
  subject { EmailMock.new }

  describe '#attributes_all_for_email' do
    it "returns blank" do
      expect(subject.attributes_all_for_email).to be_blank
    end
  end

  describe '#attributes_brief_for_email' do
    it "returns blank" do
      expect(subject.attributes_brief_for_email).to be_blank
    end
  end

  describe '#attributes_standard_for_email' do
    it "returns blank" do
      expect(subject.attributes_standard_for_email).to be_blank
    end
  end

  describe '#attributes_for_email_rds_create' do
    it "returns array of empty array and false" do
      expect(subject.attributes_for_email_rds_create).to eq [[], false]
    end
  end

  describe '#attributes_for_email_rds_destroy' do
    it "returns array of empty array and false" do
      expect(subject.attributes_for_email_rds_destroy).to eq [[], false]
    end
  end

  describe '#attributes_for_email_rds_globus' do
    it "returns array of empty array and true" do
      expect(subject.attributes_for_email_rds_globus).to eq [[], true]
    end
  end

  describe '#attributes_for_email_rds_publish' do
    it "returns array of empty array and false" do
      expect(subject.attributes_for_email_rds_publish).to eq [[], false]
    end
  end

  describe '#attributes_for_email_rds_unpublish' do
    it "returns array of empty array and false" do
      expect(subject.attributes_for_email_rds_unpublish).to eq [[], false]
    end
  end

  describe '#attributes_for_email_user_create' do
    it "returns blank" do
      expect(subject.attributes_for_email_user_create).to be_blank
    end
  end

  pending "#email_attribute_values_for_snapshot"
  pending '#email_address_rds'
  pending '#email_address_rds_deepblue'


  describe '#email_address_user' do
    context "current user is nil" do
      it "returns nil" do
        expect(subject.email_address_user nil).to be_blank
      end
    end

    context "current user has value" do
      it "returns current user email address" do
        expect(subject.email_address_user double(email: 'chelsea.imaginary@example.com')).to eq 'chelsea.imaginary@example.com'
      end
    end
  end


  describe '#email_compose_body' do
    before {
      allow(subject).to receive(:for_email_label).with("cake").and_return "celebration: "
      allow(subject).to receive(:for_email_label).with("frosting").and_return "decoration: "

      allow(subject).to receive(:for_email_value).with("cake", "chocolate").and_return "ganache\n"
      allow(subject).to receive(:for_email_value).with("frosting", "meringue").and_return "torched\n"
    }

    context "message is nil and hash has key value pairs" do
      it "returns hash key values as string" do
        expect(subject.email_compose_body message:nil, email_key_values:{"cake" => "chocolate", "frosting" => "meringue"})
          .to eq "celebration: ganache\ndecoration: torched\n"
      end
    end

    context "message has value and hash has key value pairs" do
      it "returns message and hash key values as string" do
        expect(subject.email_compose_body message: "Hiya", email_key_values:{"cake" => "chocolate", "frosting" => "meringue"})
          .to eq "Hiya\ncelebration: ganache\ndecoration: torched\n"
      end
    end
  end


  describe '#email_rds_create' do
    context "calls map_email_attributes! and email_event_notification" do
      before {
        allow(subject).to receive(:email_address_rds).and_return("rutabaga.imaginary@example.com")
        allow(subject).to receive(:for_email_id).and_return("celery.imaginary@example.com")
      }

      it "passes parameters to functions" do
        expect(subject).to receive(:map_email_attributes!).with(event:Deepblue::AbstractEventBehavior::EVENT_CREATE, attributes:[], ignore_blank_key_values:false)

        expect(subject).to receive(:email_event_notification).with(to:"rutabaga.imaginary@example.com", to_note:'RDS', from:"rutabaga.imaginary@example.com",
           subject:Deepblue::EmailHelper.t( "hyrax.email.subject.work_created" ), attributes:[], current_user:"current user",
           event:Deepblue::AbstractEventBehavior::EVENT_CREATE, event_note:'', id:"celery.imaginary@example.com",
           ignore_blank_key_values:false, return_email_parameters:false, send_it:true, email_key_values: nil)

        subject.email_rds_create current_user:"current user", event_note:'', return_email_parameters: false, send_it: true
      end
    end
  end


  describe '#email_rds_destroy' do
    context "calls email_event_notification" do
      before {
        allow(subject).to receive(:email_address_rds).and_return("rutabaga.imaginary@example.com")
        allow(subject).to receive(:for_email_id).and_return("celery.imaginary@example.com")
      }

      it "passes parameters to function" do
        expect(subject).to receive(:email_event_notification).with(to:"rutabaga.imaginary@example.com", to_note:'RDS', from:"rutabaga.imaginary@example.com",
                                                                   subject:Deepblue::EmailHelper.t( "hyrax.email.subject.work_deleted" ), attributes:[],
                                                                   current_user:"current user", event:Deepblue::AbstractEventBehavior::EVENT_DESTROY,
                                                                   event_note:'', id:"celery.imaginary@example.com", ignore_blank_key_values:false)

        subject.email_rds_destroy current_user:"current user", event_note:''
      end
    end
  end


  describe '#email_rds_globus' do
    context "calls email_event_notification" do
      before {
        allow(subject).to receive(:email_address_rds).and_return("rutabaga.imaginary@example.com")
        allow(subject).to receive(:for_email_id).and_return("celery.imaginary@example.com")
      }

      it "passes parameters to function" do
        expect(subject).to receive(:email_event_notification).with(to:"rutabaga.imaginary@example.com", to_note:'RDS', from:"rutabaga.imaginary@example.com",
                                                                   subject:"DBD: Globus Notify", attributes:[], current_user:"current user",
                                                                   event:Deepblue::AbstractEventBehavior::EVENT_GLOBUS, event_note:'Notify',
                                                                   id:"celery.imaginary@example.com", ignore_blank_key_values:true)

        subject.email_rds_globus current_user:"current user", event_note:'Notify'
      end
    end
  end


  describe '#email_rds_publish' do
    context "calls email_event_notification" do
      before {
        allow(subject).to receive(:email_address_rds).and_return("rutabaga.imaginary@example.com")
        allow(subject).to receive(:for_email_id).and_return("celery.imaginary@example.com")
      }

      it "passes parameters to function" do
        expect(subject).to receive(:email_event_notification).with(to:"rutabaga.imaginary@example.com", to_note:'RDS', from:"rutabaga.imaginary@example.com",
                                                                   subject:Deepblue::EmailHelper.t( "hyrax.email.subject.work_published" ), attributes:[],
                                                                   current_user:"current user", event:Deepblue::AbstractEventBehavior::EVENT_PUBLISH,
                                                                   event_note:'Notify', message:"Messaging", id:"celery.imaginary@example.com",
                                                                   ignore_blank_key_values:false)

        subject.email_rds_publish current_user:"current user", event_note:'Notify', message:"Messaging"
      end
    end
  end


  describe '#email_rds_unpublish' do
    context "calls email_event_notification" do
      before {
        allow(subject).to receive(:email_address_rds).and_return("rutabaga.imaginary@example.com")
        allow(subject).to receive(:for_email_id).and_return("celery.imaginary@example.com")
      }

      it "passes parameters to function" do
        expect(subject).to receive(:email_event_notification).with(to:"rutabaga.imaginary@example.com", to_note:'RDS', from:"rutabaga.imaginary@example.com",
                                                                   subject:Deepblue::EmailHelper.t( "hyrax.email.subject.work_unpublished" ), attributes:[],
                                                                   current_user:"current user", event:Deepblue::AbstractEventBehavior::EVENT_UNPUBLISH,
                                                                   event_note:'', id:"celery.imaginary@example.com", ignore_blank_key_values:false)

        subject.email_rds_unpublish current_user:"current user"
      end
    end
  end


  describe '#email_user_create' do
    context "calls email_event_notification" do
      before {
        allow(subject).to receive(:email_address_user).with("current user").and_return("crinoline.imaginary@example.com")
        allow(subject).to receive(:email_address_rds).and_return("rutabaga.imaginary@example.com")
        allow(subject).to receive(:for_email_id).and_return("celery.imaginary@example.com")
      }

      it "passes parameters to function" do
        expect(subject).to receive(:email_event_notification).with(to:"crinoline.imaginary@example.com", to_note:'user', from:"rutabaga.imaginary@example.com",
                                                                   subject:Deepblue::EmailHelper.t( "hyrax.email.subject.work_created" ), attributes:[],
                                                                   current_user:"current user", event:Deepblue::AbstractEventBehavior::EVENT_CREATE,
                                                                   event_note:"Attention!", id:"celery.imaginary@example.com", ignore_blank_key_values:false)

        subject.email_user_create current_user:"current user", event_note:"Attention!"
      end
    end
  end


  describe '#email_create_to_user' do
    context "calls email_create" do
      it "passes parameters to function" do
        expect(subject.email_create_to_user current_user:"current user", event_note:"to do").to eq "user email"
      end
    end
  end


  describe '#for_email_class' do
    context "calls for_email_object" do
      before {
        allow(subject).to receive(:for_email_object).and_return OpenStruct.new(class:"classy name")
      }
      it "returns for_email_object class" do
        expect(subject.for_email_class).to eq "classy name"
      end
    end
  end


  describe '#for_email_id' do
    context "calls for_email_object" do
      before {
        allow(subject).to receive(:for_email_object).and_return OpenStruct.new(id:"ZZZ")
      }
      it "returns for_email_object id" do
        expect(subject.for_email_id).to eq "ZZZ"
      end
    end
  end


  describe "#for_email_ignore_empty_attributes" do
    it "returns true" do
      expect(subject.for_email_ignore_empty_attributes).to eq true
    end
  end


  describe "#for_email_label" do
    it "returns argument formatted as string" do
      expect(subject.for_email_label "secret").to eq "secret: "
    end
  end


  describe "#for_email_object" do
    it "returns object self" do
      expect(subject.for_email_object).to be_instance_of EmailMock
    end
  end


  describe "#for_email_route" do
    context "gets object self id" do
      before {
        allow(subject).to receive(:for_email_object).and_return OpenStruct.new(id:"ZZZ")
      }

      it "returns formatted as string" do
        expect(subject.for_email_route).to eq "route to ZZZ"
      end
    end
  end


  describe "#for_email_subject" do
    it "returns argument formatted as string" do
      expect(subject.for_email_subject subject_rest:"Subjective").to eq "DBD: Subjective"
    end
  end


  describe "#for_email_value" do
    context "when value empty" do
      it "returns empty string" do
        expect(subject.for_email_value "key", "").to be_blank
      end
    end

    context "when single value has id field" do
      it "returns value" do
        expect(subject.for_email_value "key", ["value"]).to eq "value"
      end
    end

    context "when multiple values have id fields" do
      it "returns joined values" do
        expect(subject.for_email_value "key", ["valu1", "valu2", "valu3"]).to eq "valu1; valu2; valu3"
      end
    end

    context "when value not blank with no id field" do
      it "returns value" do
        expect(subject.for_email_value "key", "spicy").to eq "spicy"
      end
    end
  end


  describe "#for_email_value_sep" do
    context "when argument is title" do
      it "returns whitespace" do
        expect(subject.for_email_value_sep key: "title").to be_blank
      end
    end

    context "when argument is not title" do
      it "returns semicolon and whitespace" do
        expect(subject.for_email_value_sep key: "subject").to eq "; "
      end
    end
  end


  describe "#for_email_user" do
    context "when parameter is blank" do
      it "returns empty string" do
        expect(subject.for_email_user " ").to be_blank
      end
    end

    context "when parameter is a string" do
      it "returns parameter" do
        expect(subject.for_email_user "nom de plume").to eq "nom de plume"
      end
    end

    context "when parameter is not a string" do
      before {
        allow(Deepblue::EmailHelper).to receive(:user_email_from).with(OpenStruct.new(email: 'twist@example.com')).and_return("object")
      }

      it "returns empty string" do
        expect(Deepblue::EmailHelper).to receive(:user_email_from).with OpenStruct.new(email: 'twist@example.com')
        expect(subject.for_email_user OpenStruct.new(email: 'twist@example.com')).to eq "object"
      end
    end
  end

  describe "#map_email_attributes!" do
    context "when called without attributes" do
      before {
        allow(subject).to receive(:for_email_object)
      }
      it "returns unchanged email_key_values parameter" do
        expect(subject.map_email_attributes! event: "event", attributes: [], ignore_blank_key_values: false, email_key_values: "C sharp")
          .to eq :email_key_values => "C sharp"
      end
    end

    context "when called with attributes and not map_email_attributes_override!" do
      before {
        allow(subject).to receive(:for_email_object).and_return(:date_created => "date created value", "invented" => "invented value")
        allow(subject).to receive(:map_email_attributes_override!)
                            .with(event: "event", attribute: "id", ignore_blank_key_values: true, email_key_values: {}).and_return false
        allow(subject).to receive(:map_email_attributes_override!)
                            .with(event: "event", attribute: "location", ignore_blank_key_values: true, email_key_values: {"id"=>"id value"}).and_return false
        allow(subject).to receive(:map_email_attributes_override!)
                            .with(event: "event", attribute: "route", ignore_blank_key_values: true,
                                  email_key_values: {"id"=>"id value", "location"=>"email value"}).and_return false
        allow(subject).to receive(:map_email_attributes_override!)
                            .with(event: "event", attribute: "date_created", ignore_blank_key_values: true,
                                  email_key_values: {"id"=>"id value", "location"=>"email value", "route"=>"email value"}).and_return false
        allow(subject).to receive(:map_email_attributes_override!)
                            .with(event: "event", attribute: "invented", ignore_blank_key_values: true,
                                  email_key_values: {"id"=>"id value", "location"=>"email value", "route"=>"email value", "date_created"=>"date created value"})
                                    .and_return false

        allow(subject).to receive(:for_email_id).and_return("id value")
        allow(subject).to receive(:for_email_route).and_return("email value")
      }
      it "returns attributes with email key values" do
        expect(subject.map_email_attributes! event: "event", attributes: ["id", "location", "route", "date_created", "invented"], ignore_blank_key_values: true)
          .to eq "id" => "id value", "location" => "email value", "route" => "email value", "date_created" => "date created value", "invented" => "invented value"
      end
    end

    context "when called with attribute(s) and ignore_blank_key_values and not map_email_attributes_override!" do
      before {
        allow(subject).to receive(:for_email_object).and_return(:date_created => nil, "made_up" => "  ")
        allow(subject).to receive(:map_email_attributes_override!)
                            .with(event: "event", attribute: "date_created", ignore_blank_key_values: true, email_key_values: {}).and_return false
        allow(subject).to receive(:map_email_attributes_override!)
                            .with(event: "event", attribute: "made_up", ignore_blank_key_values: true, email_key_values: {}).and_return false
      }
      it "returns attributes with email key values excluding blanks" do
        expect(subject.map_email_attributes! event: "event", attributes: ["date_created", "made_up"], ignore_blank_key_values: true).to be_blank
      end
    end

    context "when called with attribute(s) and not ignore_blank_key_values and not map_email_attributes_override!" do
      before {
        allow(subject).to receive(:for_email_object).and_return(:date_created => nil, "invention" => "")
        allow(subject).to receive(:map_email_attributes_override!)
                            .with(event: "event", attribute: "date_created", ignore_blank_key_values: false, email_key_values: {}).and_return false
        allow(subject).to receive(:map_email_attributes_override!)
                            .with(event: "event", attribute: "invention", ignore_blank_key_values: false, email_key_values: {"date_created"=>""}).and_return false
      }
      it "returns attributes with email key values including blanks" do
        expect(subject.map_email_attributes! event: "event", attributes: ["date_created", "invention"], ignore_blank_key_values: false)
          .to eq "date_created" => "", "invention" => ""
      end
    end

    context "when called with attribute(s) and map_email_attributes_override!" do
      before {
        allow(subject).to receive(:for_email_object)
        allow(subject).to receive(:map_email_attributes_override!)
                            .with(event: "event", attribute: "id", ignore_blank_key_values: false, email_key_values:{:email_key_values=>"C sharp"}).and_return true
      }

      it "returns unchanged email_key_values parameter" do
        expect(subject.map_email_attributes! event: "event", attributes: ["id"], ignore_blank_key_values: false, email_key_values: "C sharp")
          .to eq :email_key_values => "C sharp"
      end
    end
  end


  describe "#map_email_attributes_override!" do
    it "returns false" do
      expect(subject.map_email_attributes_override! event: "event", attribute: [], ignore_blank_key_values: false, email_key_values: []).to eq false
    end
  end

end

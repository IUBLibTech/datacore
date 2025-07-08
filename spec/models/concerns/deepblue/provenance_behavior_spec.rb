require 'rails_helper'

class ProvenanceMock
  include ::Deepblue::ProvenanceBehavior

  def id
    1001
  end

  def has_attribute?(attr)
    false
  end

  def berry_farm

  end
end

RSpec.describe Deepblue::ProvenanceBehavior do
  subject { ProvenanceMock.new }

  describe "#attributes_all_for_provenance" do
    it "returns empty array" do
      expect(subject.attributes_all_for_provenance).to be_blank
    end
  end

  describe "#attributes_brief_for_provenance" do
    it "returns empty array" do
      expect(subject.attributes_brief_for_provenance).to be_blank
    end
  end

  describe "#attributes_virus_for_provenance" do
    before {
      allow(subject).to receive(:attributes_brief_for_provenance).and_return(["omega"])
    }
    it "returns attributes_brief_for_provenance" do
      expect(subject).to receive(:attributes_brief_for_provenance)
      expect(subject.attributes_virus_for_provenance).to eq ["omega"]
    end
  end

  describe "#attributes_update_for_provenance" do
    before {
      allow(subject).to receive(:attributes_all_for_provenance).and_return(["uno", "dos", "tres"])
    }
    it "returns attributes_all_for_provenance" do
      expect(subject).to receive(:attributes_all_for_provenance)
      expect(subject.attributes_update_for_provenance).to eq ["uno", "dos", "tres"]
    end
  end

  describe "#attributes_for_provenance_add" do
    before {
      allow(subject).to receive(:attributes_brief_for_provenance).and_return(["alpha", "beta", "gamma"])
    }
    it "returns attributes_brief_for_provenance, IGNORE_BLANK_KEY_VALUES" do
      expect(subject).to receive(:attributes_brief_for_provenance)
      expect(subject.attributes_for_provenance_add).to eq [["alpha", "beta", "gamma"], true]
    end
  end

  describe "#attributes_for_provenance_characterize" do
    before {
      allow(subject).to receive(:attributes_brief_for_provenance).and_return([1,2,3])
    }
    it "returns attributes_brief_for_provenance, IGNORE_BLANK_KEY_VALUES" do
      expect(subject).to receive(:attributes_brief_for_provenance)
      expect(subject.attributes_for_provenance_characterize).to eq [[1,2,3], true]
    end
  end

  describe "#attributes_for_provenance_create" do
    before {
      allow(subject).to receive(:attributes_all_for_provenance).and_return(["apple", "orange", "pomegranate"])
    }
    it "returns attributes_all_for_provenance, USE_BLANK_KEY_VALUES" do
      expect(subject).to receive(:attributes_all_for_provenance)
      expect(subject.attributes_for_provenance_create).to eq [["apple", "orange", "pomegranate"], false]
    end
  end

  describe "#attributes_for_provenance_create_derivative" do
    before {
      allow(subject).to receive(:attributes_brief_for_provenance).and_return(["lemon", "lime", "bergamot"])
    }
    it "returns attributes_brief_for_provenance, USE_BLANK_KEY_VALUES" do
      expect(subject).to receive(:attributes_brief_for_provenance)
      expect(subject.attributes_for_provenance_create_derivative).to eq [["lemon", "lime", "bergamot"], false]
    end
  end

  describe "#attributes_for_provenance_destroy" do
    before {
      allow(subject).to receive(:attributes_all_for_provenance).and_return(["un", "deux", "trois"])
    }
    it "returns attributes_all_for_provenance, USE_BLANK_KEY_VALUES" do
      expect(subject).to receive(:attributes_all_for_provenance)
      expect(subject.attributes_for_provenance_destroy).to eq [["un", "deux", "trois"], false]
    end
  end

  describe "#attributes_for_provenance_embargo" do
    before {
      allow(subject).to receive(:attributes_all_for_provenance).and_return("ceci n'est pas un gateaux")
    }
    it "returns attributes_all_for_provenance, USE_BLANK_KEY_VALUES" do
      expect(subject).to receive(:attributes_all_for_provenance)
      expect(subject.attributes_for_provenance_embargo).to eq ["ceci n'est pas un gateaux", false]
    end
  end

  describe "#attributes_for_provenance_fixity_check" do
    before {
      allow(subject).to receive(:attributes_brief_for_provenance).and_return("brevity")
    }
    it "returns attributes_brief_for_provenance, IGNORE_BLANK_KEY_VALUES" do
      expect(subject).to receive(:attributes_brief_for_provenance)
      expect(subject.attributes_for_provenance_fixity_check).to eq ["brevity", true]
    end
  end

  describe "#attributes_for_provenance_ingest" do
    before {
      allow(subject).to receive(:attributes_all_for_provenance).and_return("Herbes de Provence")
    }
    it "returns attributes_all_for_provenance, USE_BLANK_KEY_VALUES" do
      expect(subject).to receive(:attributes_all_for_provenance)
      expect(subject.attributes_for_provenance_ingest).to eq ["Herbes de Provence", false]
    end
  end

  describe "#attributes_for_provenance_migrate" do
    before {
      allow(subject).to receive(:attributes_brief_for_provenance).and_return("lavender")
    }
    it "returns attributes_brief_for_provenance, IGNORE_BLANK_KEY_VALUES" do
      expect(subject).to receive(:attributes_brief_for_provenance)
      expect(subject.attributes_for_provenance_migrate).to eq ["lavender", true]
    end
  end

  describe "#attributes_for_provenance_mint_doi" do
    before {
      allow(subject).to receive(:attributes_all_for_provenance).and_return(1001)
    }
    it "returns attributes_all_for_provenance, USE_BLANK_KEY_VALUES" do
      expect(subject).to receive(:attributes_all_for_provenance)
      expect(subject.attributes_for_provenance_mint_doi).to eq [1001, false]
    end
  end

  describe "#attributes_for_provenance_publish" do
    before {
      allow(subject).to receive(:attributes_all_for_provenance).and_return(3.14159)
    }
    it "returns attributes_all_for_provenance, USE_BLANK_KEY_VALUES" do
      expect(subject).to receive(:attributes_all_for_provenance)
      expect(subject.attributes_for_provenance_publish).to eq [3.14159, false]
    end
  end

  describe "#attributes_for_provenance_tombstone" do
    before {
      allow(subject).to receive(:attributes_all_for_provenance).and_return(22)
    }
    it "returns attributes_all_for_provenance, USE_BLANK_KEY_VALUES" do
      expect(subject).to receive(:attributes_all_for_provenance)
      expect(subject.attributes_for_provenance_tombstone).to eq [22, false]
    end
  end

  describe "#attributes_for_provenance_unembargo" do
    before {
      allow(subject).to receive(:attributes_all_for_provenance).and_return("quixotic")
    }
    it "returns attributes_all_for_provenance, USE_BLANK_KEY_VALUES" do
      expect(subject).to receive(:attributes_all_for_provenance)
      expect(subject.attributes_for_provenance_unembargo).to eq ["quixotic", false]
    end
  end

  describe "#attributes_for_provenance_unpublish" do
    before {
      allow(subject).to receive(:attributes_all_for_provenance).and_return("tristesse")
    }
    it "returns attributes_all_for_provenance, USE_BLANK_KEY_VALUES" do
      expect(subject).to receive(:attributes_all_for_provenance)
      expect(subject.attributes_for_provenance_unpublish).to eq ["tristesse", false]
    end
  end

  describe "#attributes_for_provenance_update" do
    before {
      allow(subject).to receive(:attributes_update_for_provenance).and_return("impossible")
    }
    it "returns attributes_update_for_provenance, IGNORE_BLANK_KEY_VALUES" do
      expect(subject).to receive(:attributes_update_for_provenance)
      expect(subject.attributes_for_provenance_update).to eq ["impossible", true]
    end
  end

  describe "#attributes_for_provenance_update_version" do
    before {
      allow(subject).to receive(:attributes_update_for_provenance).and_return("betwixt and between")
    }
    it "returns attributes_update_for_provenance, IGNORE_BLANK_KEY_VALUES" do
      expect(subject).to receive(:attributes_update_for_provenance)
      expect(subject.attributes_for_provenance_update_version).to eq ["betwixt and between", true]
    end
  end

  describe "#attributes_for_provenance_upload" do
    before {
      allow(subject).to receive(:attributes_all_for_provenance).and_return("sabotage")
    }
    it "returns attributes_all_for_provenance, USE_BLANK_KEY_VALUES" do
      expect(subject).to receive(:attributes_all_for_provenance)
      expect(subject.attributes_for_provenance_upload).to eq ["sabotage", false]
    end
  end

  describe "#attributes_for_provenance_virus_scan" do
    before {
      allow(subject).to receive(:attributes_virus_for_provenance).and_return("virii is not latin")
    }
    it "returns attributes_virus_for_provenance, IGNORE_BLANK_KEY_VALUES" do
      expect(subject).to receive(:attributes_virus_for_provenance)
      expect(subject.attributes_for_provenance_virus_scan).to eq ["virii is not latin", true]
    end
  end

  describe "#attributes_for_provenance_workflow" do
    before {
      allow(subject).to receive(:attributes_brief_for_provenance).and_return("apparatchik")
    }
    it "returns attributes_brief_for_provenance, IGNORE_BLANK_KEY_VALUES" do
      expect(subject).to receive(:attributes_brief_for_provenance)
      expect(subject.attributes_for_provenance_workflow).to eq ["apparatchik", true]
    end
  end

  describe "#attributes_cache_fetch" do
    before {
      allow(subject).to receive(:attributes_cache_key).with(event: "event", id: "121").and_return("XYZ")
      allow(Rails.cache).to receive(:fetch).with("XYZ").and_return("attributes")
    }
    it "returns attributes cache by event id" do
      expect(subject).to receive(:attributes_cache_key).with(event: "event", id: "121")
      expect(Rails.cache).to receive(:fetch)
      expect(subject.attributes_cache_fetch event: "event", id: "121").to eq "attributes"
    end
  end

  describe "#attributes_cache_key" do
    it "returns parameters as string" do
      expect(subject.attributes_cache_key event: "event", id: "121").to eq "121.event"
    end
  end

  describe "#attributes_cache_write" do
    before {
      allow(subject).to receive(:attributes_cache_key).with(event: "event", id: "171").and_return("A.B-C")
    }
    it "calls Rails.cache.write" do
      expect(subject).to receive(:attributes_cache_key).with(event: "event", id: "171")
      expect(Rails.cache).to receive(:write).with("A.B-C", "attributes")
      subject.attributes_cache_write( event: "event", id: "171", attributes: "attributes" )
    end
  end

  describe "#for_provenance_event_cache_exist?" do
    before {
      allow(subject).to receive(:for_provenance_event_cache_key).with(event: "event", id: "181").and_return("key")
      allow(Rails.cache).to receive(:exist?).with("key").and_return true
    }
    it "calls Rails.cache.exist?" do
      expect(subject).to receive(:for_provenance_event_cache_key).with(event: "event", id: "181")
      expect(Rails.cache).to receive(:exist?).with("key")
      expect(subject.for_provenance_event_cache_exist? event: "event", id: "181" ).to eq true
    end
  end

  describe "#for_provenance_event_cache_fetch" do
    before {
      allow(subject).to receive(:for_provenance_event_cache_key).with(event: "event", id: "191").and_return("key")
      allow(Rails.cache).to receive(:fetch).with("key").and_return "it was cached"
    }
    it "calls Rails.cache.fetch" do
      expect(subject).to receive(:for_provenance_event_cache_key).with(event: "event", id: "191")
      expect(Rails.cache).to receive(:fetch).with("key")
      expect(subject.for_provenance_event_cache_fetch event: "event", id: "191" ).to eq "it was cached"
    end
  end

  describe "#for_provenance_event_cache_key" do
    it "returns string" do
      expect(subject.for_provenance_event_cache_key event: "evening_event", id: "202" ).to eq "202.evening_event.provenance"
    end
  end

  describe "#for_provenance_event_cache_key" do
    it "returns string" do
      expect(subject.for_provenance_event_cache_key event: "evening_event", id: "202" ).to eq "202.evening_event.provenance"
    end
  end

  describe "#for_provenance_class" do
    it "returns type of object self" do
      expect(subject.for_provenance_class).to eq ProvenanceMock
    end
  end

  describe "#for_provenance_id" do
    it "returns id of object self" do
      expect(subject.for_provenance_id).to eq 1001
    end
  end

  describe "#for_provenance_ignore_empty_attributes" do
    it "returns true" do
      expect(subject.for_provenance_ignore_empty_attributes).to eq true
    end
  end

  describe "#for_provenance_object" do
    it "returns self" do
      expect(subject.for_provenance_object).to eq subject
    end
  end

  describe "#for_provenance_route" do
    it "returns string" do
      expect(subject.for_provenance_route).to eq "route to 1001"
    end
  end

  describe "#for_provenance_user" do
    context "when current user is blank" do
      it "returns empty string" do
        expect(subject.for_provenance_user nil).to be_blank
      end
    end

    context "when current user is a string that is not blank" do
      it "returns same parameter passed in" do
        expect(subject.for_provenance_user "user1@example.com").to eq "user1@example.com"
      end
    end

    context "when current user is not a string" do
      user_obj = OpenStruct.new(id: '33')

      before {
        allow(Deepblue::EmailHelper).to receive(:user_email_from).with(user_obj).and_return "user2@example.com"
      }
      it "calls EmailHelper.user_email_from" do
        expect(subject.for_provenance_user user_obj).to eq "user2@example.com"
      end
    end
  end

  describe "#map_provenance_attributes!" do
    context "when no attributes present" do
      it "returns prov_key_values passed in" do
        expect(subject.map_provenance_attributes! event: "event", attributes: [], ignore_blank_key_values: true, prov_key_values: ["buttercream", "toasted meringue", "ganache"]).
          to eq :prov_key_values=>["buttercream", "toasted meringue", "ganache"]
      end
    end

    context "when attributes present and map_provenance_attributes_override! returns true" do
      before {
        allow(subject).to receive(:map_provenance_attributes_override!).with(event: "event",
                                                                             attribute: "berry farm",
                                                                             ignore_blank_key_values: true,
                                                                             prov_key_values: {:prov_key_values=>"strawberry"}).and_return true
      }
      it "returns prov_key_values passed in" do
        expect(subject.map_provenance_attributes! event: "event", attributes: ["berry farm"], ignore_blank_key_values: true, prov_key_values: "strawberry").
          to eq :prov_key_values=>"strawberry"
      end
    end

    context "when attribute(s) present and map_provenance_attributes_override! returns false and self object does not have attribute" do
      before {
        allow(subject).to receive(:berry_farm).and_return false
        allow(subject).to receive(:map_provenance_attributes_override!).with(event: "event",
                                                                             attribute: "berry_farm",
                                                                             ignore_blank_key_values: true,
                                                                             prov_key_values: {:prov_key_values=>"berry"}).and_return false
      }
      it "returns prov_key_values passed in and missing attribute" do
        expect(subject.map_provenance_attributes! event: "event", attributes: ["berry_farm"], ignore_blank_key_values: true, prov_key_values: "berry").
          to eq "berry_farm"=>"MISSING_ATTRIBUTE", :prov_key_values=>"berry"
      end
    end

    context "when attribute(s) present and map_provenance_attributes_override! returns false and self object has attribute" do
      skip "Add a test"
    end

    context "when id attribute present and map_provenance_attributes_override! returns false" do
      before {
        allow(subject).to receive(:map_provenance_attributes_override!).with(event: "event",
                                                                             attribute: "id",
                                                                             ignore_blank_key_values: true,
                                                                             prov_key_values: {:prov_key_values=>"berry"}).and_return false
      }
      it "returns prov_key_values passed in and id value" do
        expect(subject.map_provenance_attributes! event: "event", attributes: ["id"], ignore_blank_key_values: true, prov_key_values: "berry").
          to eq "id"=>1001, :prov_key_values=>"berry"
      end
    end

    context "when location attribute present and map_provenance_attributes_override! returns false" do
      before {
        allow(subject).to receive(:map_provenance_attributes_override!).with(event: "event",
                                                                             attribute: "location",
                                                                             ignore_blank_key_values: true,
                                                                             prov_key_values: {:prov_key_values=>"berry"}).and_return false
      }
      it "returns prov_key_values passed in and location value" do
        expect(subject.map_provenance_attributes! event: "event", attributes: ["location"], ignore_blank_key_values: true, prov_key_values: "berry").
          to eq "location"=>"route to 1001", :prov_key_values=>"berry"
      end
    end

    context "when route attribute present and map_provenance_attributes_override! returns false" do
      before {
        allow(subject).to receive(:map_provenance_attributes_override!).with(event: "event",
                                                                             attribute: "route",
                                                                             ignore_blank_key_values: true,
                                                                             prov_key_values: {:prov_key_values=>"berry"}).and_return false
      }
      it "returns prov_key_values passed in and route value" do
        expect(subject.map_provenance_attributes! event: "event", attributes: ["route"], ignore_blank_key_values: true, prov_key_values: "berry").
          to eq "route"=>"route to 1001", :prov_key_values=>"berry"
      end
    end

    context "when date_created attribute present and map_provenance_attributes_override! returns false and date_created is blank and ignore_blank_key_values is true" do
      before {
        allow(subject).to receive(:for_provenance_object).and_return(:date_created => nil)
        allow(subject).to receive(:map_provenance_attributes_override!).with(event: "event",
                                                                             attribute: "date_created",
                                                                             ignore_blank_key_values: true,
                                                                             prov_key_values: {:prov_key_values=>"berry"}).and_return false
      }
      it "returns prov_key_values passed in" do
        expect(subject.map_provenance_attributes! event: "event", attributes: ["date_created"], ignore_blank_key_values: true, prov_key_values: "berry").
          to eq :prov_key_values=>"berry"
      end
    end

    context "when date_created attribute present and map_provenance_attributes_override! returns false and date_created is blank and ignore_blank_key_values is false" do
      before {
        allow(subject).to receive(:for_provenance_object).and_return(:date_created => nil)
        allow(subject).to receive(:map_provenance_attributes_override!).with(event: "event",
                                                                             attribute: "date_created",
                                                                             ignore_blank_key_values: false,
                                                                             prov_key_values: {:prov_key_values=>"berry"}).and_return false
      }
      it "returns prov_key_values passed in and empty string for date_created" do
        expect(subject.map_provenance_attributes! event: "event", attributes: ["date_created"], ignore_blank_key_values: false, prov_key_values: "berry").
          to eq "date_created"=>"", :prov_key_values=>"berry"
      end
    end

    context "when date_created attribute present and map_provenance_attributes_override! returns false and date_created has a value" do
      before {
        allow(subject).to receive(:for_provenance_object).and_return(:date_created => DateTime.new(2000, 12, 31))
        allow(subject).to receive(:map_provenance_attributes_override!).with(event: "event",
                                                                             attribute: "date_created",
                                                                             ignore_blank_key_values: true,
                                                                             prov_key_values: {:prov_key_values=>"berry"}).and_return false
      }
      it "returns prov_key_values passed in and date_created value" do
        expect(subject.map_provenance_attributes! event: "event", attributes: ["date_created"], ignore_blank_key_values: true, prov_key_values: "berry").
          to eq "date_created"=>DateTime.new(2000, 12, 31), :prov_key_values=>"berry"
      end
    end


  end

end

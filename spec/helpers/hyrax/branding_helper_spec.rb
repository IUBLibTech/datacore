class BrandingHelperMock
  include ::Hyrax::BrandingHelper

end


RSpec.describe Hyrax::BrandingHelper, type: :helper do

  subject { BrandingHelperMock.new }

  describe "#branding_banner_file" do

    context "when CollectionBrandingInfo.where returns result" do
      before {
        allow(CollectionBrandingInfo).to receive(:where).with(collection_id: "666NB", role: "banner").and_return ["first"]
        allow(subject).to receive(:brand_path).with(collection_branding_info: "first")
      }

      it "calls brand_path" do
        expect(CollectionBrandingInfo).to receive(:where).with(collection_id: "666NB", role: "banner")
        expect(subject).to receive(:brand_path).with(collection_branding_info: "first")

        subject.branding_banner_file(id: "666NB")
      end
    end

    context "when CollectionBrandingInfo.where does NOT return result" do
      before {
        allow(CollectionBrandingInfo).to receive(:where).with(collection_id: "777FW", role: "banner").and_return []
      }

      it "does not call brand_path" do
        expect(CollectionBrandingInfo).to receive(:where).with(collection_id: "777FW", role: "banner")
        expect(subject).not_to receive(:brand_path).with(collection_branding_info: "first")

        subject.branding_banner_file(id: "777FW")
      end
    end
  end


  describe "#branding_logo_record" do
    context "when no CollectionBrandingInfo with collection id and logo role" do
      before {
        allow(CollectionBrandingInfo).to receive(:where).with(collection_id: "Eye D", role: "logo").and_return []
      }
      it "returns nil" do
        expect(CollectionBrandingInfo).to receive(:where).with(collection_id: "Eye D", role: "logo")

        expect(subject.branding_logo_record(id: "Eye D")).to be_nil
      end
    end

    context "when CollectionBrandingInfo with collection id and logo role is found" do

      context "when object has logo file on local path" do
        info = OpenStruct.new(local_path: "/home/user/documents/report.pdf", alt_text: "Alt text", target_url: "target/url")
        before {
          allow(CollectionBrandingInfo).to receive(:where).with(collection_id: "Eye D", role: "logo").and_return [info]
          allow(subject).to receive(:brand_path).with(collection_branding_info: info).and_return "file/location"
        }
        it "returns file branding info for collection including logo file location" do
          expect(subject).to receive(:brand_path).with(collection_branding_info: info)
          expect(CollectionBrandingInfo).to receive(:where).with(collection_id: "Eye D", role: "logo")

          expect(subject.branding_logo_record(id: "Eye D")).to eq [:file => "report.pdf", :file_location => "file/location",
                                                                   :alttext => "Alt text", :linkurl => "target/url"]
        end
      end

      context "when object does NOT have logo file on local path" do
        info = OpenStruct.new(local_path: "", alt_text: "Alt text", target_url: "target/url")
        before {
          allow(CollectionBrandingInfo).to receive(:where).with(collection_id: "Eye D", role: "logo").and_return [info]
        }
        it "returns file branding info for collection minus logo file location" do
          expect(subject).not_to receive(:brand_path).with(collection_branding_info: info)
          expect(CollectionBrandingInfo).to receive(:where).with(collection_id: "Eye D", role: "logo")

          expect(subject.branding_logo_record(id: "Eye D")).to eq [:file => "", :file_location => nil,
                                                                   :alttext => "Alt text", :linkurl => "target/url"]
        end
      end
    end
  end


  describe "#brand_path" do
    context "when local path field on parameter is blank" do
      it "returns parameter" do
        brand_info = OpenStruct.new(local_path: "")
        expect(subject.brand_path collection_branding_info: brand_info).to eq brand_info
      end
    end

    context "when local path is NOT blank" do
      before {
        allow(DeepBlueDocs::Application.config).to receive(:relative_url_root).and_return "/relative"
        allow(Deepblue::LoggingHelper).to receive(:here).and_return "here"
        allow(Deepblue::LoggingHelper).to receive(:called_from).and_return "called from"
        allow(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from",
                                                      "collection_branding_info = #<OpenStruct local_path=\"/home/user/documents/report.pdf\">",
                                                      "local_path = /home/user/documents/report.pdf",
                                                      "local_path_relative=home/user/documents/report.pdf", ""]
        allow(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from", "rv = /relative/home/user/documents/report.pdf", ""]
      }

      it "calls Deepblue::LoggingHelper.bold_debug twice and returns relative path based on parameter" do
        expect(DeepBlueDocs::Application.config).to receive(:relative_url_root)
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from",
                                                                     "collection_branding_info = #<OpenStruct local_path=\"/home/user/documents/report.pdf\">",
                                                                     "local_path = /home/user/documents/report.pdf",
                                                                     "local_path_relative=home/user/documents/report.pdf", ""]
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with ["here", "called from", "rv = /relative/home/user/documents/report.pdf", ""]

        info_brand = OpenStruct.new(local_path: "/home/user/documents/report.pdf")
        expect(subject.brand_path collection_branding_info: info_brand).to eq "/relative/home/user/documents/report.pdf"
      end
    end
  end


  describe "#branding_banner_info" do
    context "when @banner_info has a value" do
      before {
        subject.instance_variable_set(:@banner_info, "banner_info")
      }

      it "returns @banner_info" do
        expect(subject).not_to receive(:collection_banner_info)
        expect(subject).not_to receive(:brand_path)
        expect(subject.branding_banner_info id: "QT-1000").to eq "banner_info"
        expect(subject.instance_variable_get(:@banner_info)).to eq "banner_info"
      end
    end

    context "when @banner_info has NO value" do
      context "when collection_banner_info returns empty value" do
        before {
          allow(subject).to receive(:collection_banner_info).with(id: "QT-1000").and_return ""
        }

        it "sets and returns @banner_info with nil values" do
          expect(subject).to receive(:collection_banner_info).with(id: "QT-1000")
          expect(subject).not_to receive(:brand_path)
          expect(subject.branding_banner_info id: "QT-1000").to eq file: nil, full_path: nil, relative_path: nil
          expect(subject.instance_variable_get(:@banner_info)).to eq file: nil, full_path: nil, relative_path: nil
        end
      end

      context "when collection_banner_info does NOT return empty value" do
        before {
          flag_info = OpenStruct.new(local_path: "home/user/notes/source.xlsx")
          allow(subject).to receive(:collection_banner_info).with(id: "QT-1000").and_return [flag_info]
          allow(subject).to receive(:brand_path).with(collection_branding_info: flag_info).and_return "/notes/"
        }

        it "sets and returns @banner_info" do
          expect(subject).to receive(:collection_banner_info).with(id: "QT-1000")
          expect(subject).to receive(:brand_path)
          expect(subject.branding_banner_info id: "QT-1000").to eq file: "source.xlsx", full_path: "home/user/notes/source.xlsx", relative_path: "/notes/"
          expect(subject.instance_variable_get(:@banner_info)).to eq file: "source.xlsx", full_path: "home/user/notes/source.xlsx", relative_path: "/notes/"
        end
      end
    end
  end


  describe "#branding_logo_info" do
    context "when @logo_info has a value" do
      before {
        subject.instance_variable_set(:@logo_info, "logo_info")
      }

      it "returns @logo_info" do
        expect(subject).not_to receive(:collection_logo_info)
        expect(subject).not_to receive(:brand_path)
        expect(subject.branding_logo_info id: "BC-3000").to eq "logo_info"
        expect(subject.instance_variable_get(:@logo_info)).to eq "logo_info"
      end
    end

    context "when @logo_info has NO value" do
      context "when collection_logo_info does NOT return logo file" do
        before {
          sigil_info = OpenStruct.new(local_path: "", alt_text: "Alt text", target_url: "target/url")
          allow(subject).to receive(:collection_logo_info).with(id: "BC-3000").and_return [sigil_info]
        }

        it "sets and returns @logo_info with some empty values" do
          expect(subject).to receive(:collection_logo_info).with(id: "BC-3000")
          expect(subject).not_to receive(:brand_path)
          expect(subject.branding_logo_info id: "BC-3000").to eq [file: "", full_path: "", relative_path: nil, alttext: "Alt text", linkurl: "target/url"]
          expect(subject.instance_variable_get(:@logo_info)).to eq [file: "", full_path: "", relative_path: nil, alttext: "Alt text", linkurl: "target/url"]
        end
      end

      context "when collection_logo_info does return logo file" do
        before {
          sigil_info = OpenStruct.new(local_path: "home/user/documents/notes.txt", alt_text: "Alt text", target_url: "target/url")
          allow(subject).to receive(:collection_logo_info).with(id: "BC-3000").and_return [sigil_info]
          allow(subject).to receive(:brand_path).with(collection_branding_info: sigil_info).and_return "/documents/"
        }

        it "sets and returns @logo_info with collection_logo_info values" do
          expect(subject).to receive(:collection_logo_info).with(id: "BC-3000")
          expect(subject).to receive(:brand_path)
          expect(subject.branding_logo_info id: "BC-3000").to eq [file: "notes.txt", full_path: "home/user/documents/notes.txt", relative_path: "/documents/", alttext: "Alt text", linkurl: "target/url"]
          expect(subject.instance_variable_get(:@logo_info)).to eq [file: "notes.txt", full_path: "home/user/documents/notes.txt", relative_path: "/documents/", alttext: "Alt text", linkurl: "target/url"]
        end
      end
    end
  end


  pending "#collection_banner_info"

  pending "#collection_logo_info"

  pending "#branding_file_save"


  describe "#branding_file_delete" do
    before {
      allow(FileUtils).to receive(:remove_file).with( "mountain trail" )
    }

    context "when File exists" do
      before {
        allow(File).to receive(:exist?).with( "mountain trail" ).and_return true
      }
      it "calls remove_file" do
        expect(FileUtils).to receive(:remove_file).with( "mountain trail" )

        subject.branding_file_delete(location_path: "mountain trail")
      end
    end

    context "when File does NOT exist" do
      before {
        allow(File).to receive(:exist?).with( "mountain trail" ).and_return false
      }
      it "does NOT call remove_file" do
        expect(FileUtils).not_to receive(:remove_file).with( "mountain trail" )

        subject.branding_file_delete(location_path: "mountain trail")
      end
    end
  end


  describe "#branding_file_find_local_filename" do
    before {
      allow(subject).to receive(:branding_file_find_local_dir_name).with(collection_id: 12, role: "significant").and_return "local dir"
      allow(File).to receive(:join).with("local dir", "good one")
    }
    it "calls File.join with local directory name" do
      expect(File).to receive(:join).with("local dir", "good one")

      subject.branding_file_find_local_filename(collection_id: 12, role: "significant", filename: "good one")
    end
  end


  describe "#branding_file_find_local_dir_name" do
    before {
      allow(Hyrax.config).to receive(:branding_path).and_return "branding path"
      allow(File).to receive(:join).with("branding path", "747", "role")
    }
    it "calls File.join with branding path and parameters" do
      expect(File).to receive(:join).with("branding path", "747", "role")

      subject.branding_file_find_local_dir_name(collection_id: 747, role: :role)
    end
  end

end



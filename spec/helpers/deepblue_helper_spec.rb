class DeepblueHelperMock
  include ::DeepblueHelper

  def request
    OpenStruct.new(env: {'HTTP_USER_AGENT' => 'http user agent'})
  end
end



RSpec.describe DeepblueHelper, type: :helper do
  subject { DeepblueHelperMock.new }

  describe "#self.display_timestamp" do
    context "when datetime_stamp_display_local_time_zone is true" do
      before {
        allow(DeepBlueDocs::Application.config).to receive(:datetime_stamp_display_local_time_zone).and_return true
      }
      it "returns a string" do
        expect(DeepblueHelper.display_timestamp DateTime.new(2025, 10, 1, 4, 30)).instance_of? String
      end
    end

    context "when datetime_stamp_display_local_time_zone is false" do
      before {
        allow(DeepBlueDocs::Application.config).to receive(:datetime_stamp_display_local_time_zone).and_return false
      }
      it "returns parameter in UTC time format as a string" do
        expect(DeepblueHelper.display_timestamp "2025-9-30 09:30:00 AM").to eq "2025-09-30 09:30:00 UTC"
      end
    end
  end


  describe "#self.human_readable_size" do
    before {
      allow(ActiveSupport::NumberHelper::NumberToHumanSizeConverter).to receive(:convert).with("value", precision: 3).and_return "human readable size"
    }

    it "calls NumberToHumanSizeConverter.convert with parameters" do
      expect(DeepblueHelper.human_readable_size"value", precision: 3).to eq "human readable size"
    end
  end


  describe "#user_agent" do
    it "returns request env HTTP_USER_AGENT" do
      expect(subject.user_agent).to eq "http user agent"
    end
  end


  describe "#users_browser" do

    browsers = [{"info" => "/msie/", "name" => "msie"},
                {"info" => "/Gecko/", "name" => "gecko"},
                {"info" => "msie Opera", "name" => "opera"},
                {"info" => "KONQUEROR", "name" => "konqueror"},
                {"info" => "/iPod", "name" => "ipod"},
                {"info" => "--iPad", "name" => "ipad"},
                {"info" => "iPhone--", "name" => "iphone"},
                {"info" => "chrome/", "name" => "chrome"},
                {"info" => "/applewebkit/", "name" => "safari"},
                {"info" => "/googlebot/", "name" => "googlebot"},
                {"info" => "MSNBOT", "name" => "msnbot"},
                {"info" => "Yahoo! Slurp.", "name" => "yahoobot"},
                {"info" => 'mozilla/5.0 (windows nt 6.3; win64, x64', "name" => "msie"},
                {"info" => 'mozilla/5.0 (windows nt 10.0; win64; x64)', "name" => "msie"},
                {"info" => "/mozilla/", "name" => "gecko"},
                {"info" => "webtv msie", "name" => "unknown"},
                {"info" => "alien", "name" => "unknown"},
    ]
    browsers.each do |browser|
      context "when browser info is #{browser["info"]}" do
        before {
          allow(subject).to receive(:user_agent).and_return browser["info"]
        }

        it "returns '#{browser["name"]}'" do
          expect(subject.users_browser).to eq browser["name"]
          expect(subject.instance_variable_get(:@users_browser)).to eq browser["name"]
        end
      end
    end

  end

end

require 'rails_helper'

class MockArchiveFile

  def get!(result)
    @result = result
  end

  def log_denied_attempt!(request_hash: metadata)
  end

  def to_s
    "MockArchiveFile"
  end
end



RSpec.describe ArchiveController, type: :controller do

  describe "#user_is_authorized?" do
    before {
      allow(subject).to receive(:set_variables)
    }

    situations = [{auth_user: true, recaptcha: true, result: true},
                  {auth_user: true, recaptcha: false, result: false},
                  {auth_user: false, recaptcha: true, result: false},
                  {auth_user: false, recaptcha: false, result: false}]

    situations.each do |situation|
      context "when authenticated_user? is #{situation[:auth_user]} and recaptcha_success? is #{situation[:recaptcha]}" do
        before {
          allow(subject).to receive(:authenticated_user?).and_return situation[:auth_user]
          allow(subject).to receive(:recaptcha_success?).and_return situation[:recaptcha]
        }

        it "sets variables and returns #{situation[:result]}" do

          expect(subject).to receive(:authenticated_user?).and_return situation[:auth_user]
          if (situation[:auth_user])
            expect(subject).to receive(:recaptcha_success?).and_return situation[:recaptcha]
          end

          expect(subject.user_is_authorized?).to eq situation[:result]
        end
      end
    end

    after {
      expect(subject).to have_received(:set_variables)
    }
  end


  describe "#status" do
    context "when user is authorized" do
      before {
        allow(subject).to receive(:user_is_authorized?).and_return true
        subject.instance_variable_set(:@archive_file, OpenStruct.new(display_status:"User is Authorized"))
        allow(subject).to receive(:render).with({plain: "User is Authorized"}).and_return "User is Authorized"
      }
      it "returns string" do
        expect(subject.status).to eq "User is Authorized"
      end
    end

    context "when user is not authorized" do
      before {
        allow(subject).to receive(:user_is_authorized?).and_return false
        allow(subject).to receive(:render).with({plain: "action unavailable", status: 403}).and_return "action unavailable 403"
      }
      it "returns 403 status" do
        expect(subject.status).to eq "action unavailable 403"
      end
    end
  end


  describe "#download_request" do
    mock_archive_file = MockArchiveFile.new
    before {
      allow(subject).to receive(:root_url).and_return "root url"
      subject.instance_variable_set(:@archive_file, mock_archive_file)
    }

    context "when user is authorized" do
      before {
        allow(subject).to receive(:user_is_authorized?).and_return true
      }

      context "when file_path is present in @archive_file" do
        before {
          allow(subject).to receive(:request_metadata).and_return :file_path => "file path", :filename => "file name"
          allow(subject).to receive(:download_filename).with("file name").and_return "download filename"
        }
        it "calls send_file" do
          expect(subject).to receive(:send_file).with("file path", filename: "download filename")
          subject.download_request
        end
      end

      context "when file_path is not present in @archive_file" do

        context "when message is not present in @archive_file" do
          before {
            allow(subject).to receive(:request_metadata).and_return :file_path => ""
            allow(Rails.logger).to receive(:error).with("Message missing from MockArchiveFile result: {:file_path=>\"\"}")
          }
          it "redirects with default error message" do
            expect(Rails.logger).to receive(:error).with("Message missing from MockArchiveFile result: {:file_path=>\"\"}")
            expect(subject).to receive(:redirect_back).with(fallback_location: "root url", notice: "Request failed.  Please seek technical support.")
            subject.download_request
          end
        end

        context "when message is present in @archive_file and alert is not" do
          before {
            allow(subject).to receive(:request_metadata).and_return :message => "message"
          }
          it "redirects with notice" do
            expect(subject).to receive(:redirect_back).with(fallback_location: "root url", notice: "message")
            subject.download_request
          end
        end

        context "when message is present in @archive_file and so is alert" do
          before {
            allow(subject).to receive(:request_metadata).and_return :message => "message", :alert => "alert"
          }
          it "redirects with alert" do
            expect(subject).to receive(:redirect_back).with(fallback_location: "root url", alert: "message")
            subject.download_request
          end
        end
      end
    end

    context "when user is not authorized" do
      before {
        allow(subject).to receive(:user_is_authorized?).and_return false
        allow(subject).to receive(:request_metadata).and_return "request metadata"
        subject.instance_variable_set(:@failure_description, "failure description")
      }
      it "logs denied attempt and calls redirect_back with @failure_description" do
        expect(mock_archive_file).to receive(:log_denied_attempt!).with(request_hash: "request metadata")
        expect(subject).to receive(:redirect_back).with(fallback_location: "root url", alert: "failure description")
        subject.download_request
      end
    end
  end


  # private methods start

  describe "#variable_params" do
    before {
      allow(subject.params).to receive(:permit).with(:collection, :object, :format, :request, :user_email, :file_set_id, 'g-recaptcha-response'.to_sym, 'g-recaptcha-response-data'.to_sym => [:sda_request])

    }
    it "calls params.permit" do
      expect(subject.params.permit(:collection, :object, :format, :request, :user_email, :file_set_id, 'g-recaptcha-response'.to_sym, 'g-recaptcha-response-data'.to_sym => [:sda_request]))
    end
  end


  describe "#set_variables" do
    before {
      allow(subject).to receive(:params).and_return :collection => "The Collection", :user_email => "user@example.com", :file_set_id => "Q-3333"
      allow(subject).to receive(:variable_params).and_return :object => "I Object", :format => "formatted"
      allow(ArchiveFile).to receive(:new).with(collection: "The Collection", object: "I Object.formatted").and_return "archive file"
    }

    it "sets instance variables" do
      subject.send(:set_variables)

      expect(subject.instance_variable_get(:@collection)).to eq "The Collection"
      expect(subject.instance_variable_get(:@object)).to eq "I Object.formatted"
      expect(subject.instance_variable_get(:@archive_file)).to eq "archive file"
      expect(subject.instance_variable_get(:@user_email)).to eq "user@example.com"
      expect(subject.instance_variable_get(:@file_set_id)).to eq "Q-3333"
    end
  end


  describe "#download_filename" do
    context "when user-displayed filename is not available" do
      before {
        allow(FileSet).to receive(:search_with_conditions).and_return []
      }
      it "returns the default filename (the parameter entered)" do
        expect(subject.send(:download_filename, "V. Basic File")).to eq "V. Basic File"
      end
    end

    context "when user-displayed filename is available" do
      before {
        subject.instance_variable_set(:@file_set_id, "B-2000")
        allow(FileSet).to receive(:search_with_conditions).with(id: "B-2000").and_return [Hash.new(label_ssi: "Descriptively labelled file with emojis")]
      }
      it "returns the user-displayed filename" do
        expect(subject.send(:download_filename, "V. Basic File")).to eq label_ssi: "Descriptively labelled file with emojis"
      end
    end
  end


  describe "#authenticated_user?" do
    context "when user authentication is not required" do
      before {
        allow(Settings.archive_api).to receive(:require_user_authentication).and_return false
      }
      it "returns true" do
        expect(subject.send(:authenticated_user?)).to eq true

        expect(subject.instance_variable_get(:@failure_description)).to be_blank
      end
    end

    context "when user authentication is required" do
      before {
        allow(Settings.archive_api).to receive(:require_user_authentication).and_return true
        allow(subject).to receive(:user_signed_in?).and_return true
      }
      it "returns result of user_signed_in?" do
        expect(subject.send(:authenticated_user?)).to eq true

        expect(subject.instance_variable_get(:@failure_description)).to eq "Action available only to signed-in users."
      end
    end
  end


  describe "#recaptcha_success?" do
    context "when recaptcha not in use" do
      before {
        allow(Settings.archive_api).to receive(:use_recaptcha).and_return false
      }
      it "returns true" do
        expect(subject.send(:recaptcha_success?)).to eq true
        expect(subject.instance_variable_get(:@failure_description)).to be_blank
      end
    end

    context "when recaptcha in use" do
      before {
        allow(Settings.archive_api).to receive(:use_recaptcha).and_return true
      }

      context "when recaptcha v3 is successful" do
        before {
          allow(subject).to receive(:verify_recaptcha).with(action: 'sda_request', minimum_score: Settings.recaptcha.minimum_score.to_f,
                                                            secret_key: Settings.recaptcha.v3.secret_key)
                                                      .and_return true
        }
        it "returns true" do
          expect(subject).to receive(:verify_recaptcha).with(action: 'sda_request', minimum_score: Settings.recaptcha.minimum_score.to_f,
                                                             secret_key: Settings.recaptcha.v3.secret_key).and_return true
          expect(subject).not_to receive(:verify_recaptcha)
          expect(subject.send(:recaptcha_success?)).to eq true
        end
      end

      context "when recaptcha v2 is successful" do
        before {
          allow(subject).to receive(:verify_recaptcha).with(action: 'sda_request', minimum_score: Settings.recaptcha.minimum_score.to_f,
                                                            secret_key: Settings.recaptcha.v3.secret_key)
                                                      .and_return false
          allow(subject).to receive(:verify_recaptcha).and_return true
        }
        it "returns true" do
          expect(subject).to receive(:verify_recaptcha).with(action: 'sda_request', minimum_score: Settings.recaptcha.minimum_score.to_f,
                                                             secret_key: Settings.recaptcha.v3.secret_key).and_return false
          expect(subject).to receive(:verify_recaptcha).and_return true
          expect(subject.send(:recaptcha_success?)).to eq true
        end
      end

      context "when recaptcha v3 and v2 are both unsuccessful" do
        before {
          allow(subject).to receive(:verify_recaptcha).with(action: 'sda_request', minimum_score: Settings.recaptcha.minimum_score.to_f,
                                                            secret_key: Settings.recaptcha.v3.secret_key)
                                                      .and_return false
          allow(subject).to receive(:verify_recaptcha).and_return false
        }
        it "returns false" do
          expect(subject).to receive(:verify_recaptcha).with(action: 'sda_request', minimum_score: Settings.recaptcha.minimum_score.to_f,
                                                             secret_key: Settings.recaptcha.v3.secret_key).and_return false
          expect(subject).to receive(:verify_recaptcha).and_return false
          expect(subject.send(:recaptcha_success?)).to eq false
        end
      end

      after {
        expect(subject.instance_variable_get(:@failure_description)).to eq 'Action requires successful recaptcha completion.'
      }
    end
  end


  describe "#request_metadata" do
    before {
      allow(Time).to receive(:now).and_return "It's time..."
      subject.instance_variable_set(:@user_email, "User's email")
      subject.instance_variable_set(:@file_set_id, "A-1000")
    }

    it "returns hashset" do
      result_hash = {:time => "It's time...", :user_email => "User's email", :file_set_id => "A-1000"}
      expect(subject.send(:request_metadata)).to eq result_hash
    end
  end

end

require 'rails_helper'

class HomepageControllerBehaviorMockParent

  def create
  end

  def verify_recaptcha(action: nil, minimum_score: nil, secret_key: nil)
  end

  def render(view_name)
  end

  def after_deliver
  end

  def flash=(message)
  end

  def flash
    OpenStruct.new(now: {:alert => nil, :notice => nil, :error => nil})
  end

  def handle_create_exception(exception)
  end
end

class ContactFormControllerBehaviorMock < HomepageControllerBehaviorMockParent
  include ::Extensions::HyraxExtensions::ContactFormController::ContactFormControllerBehavior

end




describe Extensions::HyraxExtensions::ContactFormController::ContactFormControllerBehavior do

  subject { ContactFormControllerBehaviorMock.new }

  describe "#create" do
    context "when recaptcha_success? is true" do
      before {
        allow(subject).to receive(:recaptcha_success?).and_return true
      }

      context "when @contact_form is valid" do
        valid = OpenStruct.new(valid?: true)

        before {
          subject.instance_variable_set(:@contact_form, valid)
          allow(Hyrax::ContactMailer).to receive(:contact).with(valid).and_return OpenStruct.new(deliver_now: "deliver now")
          allow(subject).to receive(:after_deliver)
          allow(Hyrax::ContactForm).to receive(:new).and_return "contact form"
        }
        it "delivers contact form and thanks user" do
          expect(Hyrax::ContactMailer).to receive(:contact).with(valid)
          expect(subject).to receive(:after_deliver)

          subject.create

          expect(subject.instance_variable_get(:@contact_form)).to eq "contact form"
        end

        skip "Add a test for flash notice message"
      end

      context "when @contact_form is NOT valid" do
        before {
          subject.instance_variable_set(:@contact_form, OpenStruct.new(valid?: false, errors: OpenStruct.new(full_messages: ["Hey.", "Hi.", 1000])))
        }
        it "" do

        end
      end
    end

    context "when recaptcha_success? is false" do
      before {
        allow(subject).to receive(:recaptcha_success?).and_return false
        allow(subject).to receive(:render).with "new"
      }
      it "calls render with 'new'" do
        expect(subject).to receive(:render).with "new"
        subject.create
      end

      skip "Add a test for flash alert message"
    end

    context "when RunTimeError occurs" do
      exception = RuntimeError.new
      before {
        allow(subject).to receive(:recaptcha_success?).and_raise(exception)
        allow(subject).to receive(:handle_create_exception).with exception
      }
      it "calls handle_create_exception" do
        expect(subject).to receive(:handle_create_exception).with exception
        subject.create
      end
    end
  end



  # private methods

  describe "#recaptcha_success?" do
    context "when Settings.archive_api.use_recaptcha is false" do
      before {
        allow(Settings.archive_api).to receive(:use_recaptcha).and_return false
      }
      it "returns true" do
        expect(subject.send(:recaptcha_success?)).to eq true
      end
    end

    context "when Settings.archive_api.use_recaptcha is true" do
      before {
        allow(Settings.archive_api).to receive(:use_recaptcha).and_return true
        allow(Settings.recaptcha).to receive(:minimum_score).and_return "0.8"
        allow(Settings.recaptcha.v3).to receive(:secret_key).and_return "V3_SECRET_KEY"
      }

      context "when v3 recaptcha is successful" do
        before {
          allow(subject).to receive(:verify_recaptcha).with(action: 'contact_form', minimum_score: 0.8, secret_key: "V3_SECRET_KEY").and_return true
        }
        it "returns true" do
          expect(subject).to receive(:verify_recaptcha).with(action: 'contact_form', minimum_score: 0.8, secret_key: "V3_SECRET_KEY")
          expect(subject).not_to receive(:verify_recaptcha)
          expect(subject.send(:recaptcha_success?)).to eq true
        end
      end

      context "when v3 recaptcha is NOT successful" do
        before {
          allow(subject).to receive(:verify_recaptcha).with(action: 'contact_form', minimum_score: 0.8, secret_key: "V3_SECRET_KEY").and_return false
        }

        context "when v2 recaptcha is successful" do
          before {
            allow(subject).to receive(:verify_recaptcha).and_return true
          }
          it "returns true" do
            expect(subject).to receive(:verify_recaptcha).with(action: 'contact_form', minimum_score: 0.8, secret_key: "V3_SECRET_KEY")

            expect(subject.send(:recaptcha_success?)).to eq true
          end
        end

        context "when v2 recaptcha is NOT successful" do
          before {
            allow(subject).to receive(:verify_recaptcha).and_return false
          }
          it "returns false" do
            expect(subject).to receive(:verify_recaptcha).with(action: 'contact_form', minimum_score: 0.8, secret_key: "V3_SECRET_KEY")

            expect(subject.send(:recaptcha_success?)).to eq false
          end
        end

        skip "Add a test for verify_recaptcha without parameters"
      end
    end
  end

end

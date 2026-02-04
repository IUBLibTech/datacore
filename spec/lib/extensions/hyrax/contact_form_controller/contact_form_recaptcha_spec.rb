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

  def params=(params)
    @params = params
  end

  def params
    @params || {}
  end
end

class ContactFormControllerBehaviorMock < HomepageControllerBehaviorMockParent
  include ::Extensions::Hyrax::ContactFormController::ContactFormRecaptcha

end




describe Extensions::Hyrax::ContactFormController::ContactFormRecaptcha do

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
    end

    context "when recaptcha_success? is false" do
      before {
        allow(subject).to receive(:recaptcha_success?).and_return false
        allow(subject).to receive(:render).with :new
      }
      it "calls render with :new" do
        expect(subject).to receive(:render).with :new
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

  describe "#contact_form_params" do
    context "when params does NOT include a key for :contact_form" do
      before {
        allow(subject.params).to receive(:key?).with(:contact_form).and_return false
      }
      it "returns empty hash" do
        expect(subject.send(:contact_form_params)).to be_empty
      end
    end

    context "when params includes a key for :contact_form" do
      before {
        allow(subject.params).to receive(:key?).with(:contact_form).and_return true
        allow(subject.params).to receive(:require).with(:contact_form)

        params_hash = { permitted: true, contact_form: { name: "Francine", email: "email", subject: "subject", category: "category",
                                contact_method: "contacted", message: "message" } }
        params_hash[:contact_form]['g-recaptcha-response'.to_sym] = "responded"
        params_hash[:contact_form]['g-recaptcha-response-data'.to_sym] = "response data"

        # Create an ActionController::Parameters instance manually for isolated testing
        subject.params = ActionController::Parameters.new(params_hash)
      }
      it ":contact_form required parameters permit allowed parameters" do
        permitted_params = subject.send(:contact_form_params)

        expect(permitted_params).to have_key(:name)
        expect(permitted_params).to have_key(:email)
        expect(permitted_params).to have_key(:subject)
        expect(permitted_params).to have_key(:category)
        expect(permitted_params).to have_key(:contact_method)
        expect(permitted_params).to have_key(:message)
        expect(permitted_params).to have_key('g-recaptcha-response'.to_sym)
        expect(permitted_params).to be_permitted
      end

      skip "Add a test for 'g-recaptcha-response-data' key"
    end
  end


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
            expect(subject).to receive(:verify_recaptcha).with(no_args)
            expect(subject.send(:recaptcha_success?)).to eq false
          end
        end
      end
    end
  end

end

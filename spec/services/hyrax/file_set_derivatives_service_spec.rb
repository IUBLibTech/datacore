require 'rails_helper'

RSpec.describe Hyrax::FileSetDerivativesService do

  subject { described_class.new("file set") }


  describe "#create_derivatives" do
    before {
      allow(Rails.logger).to receive(:debug)
      allow(subject).to receive(:monkey_create_derivatives).with "file name"
      allow(Rails.logger).to receive(:debug).with "Returned from call create_derivatives(file name)"
    }

    context "calls logger.debug and monkey_create_derivatives" do
      before {
        allow(subject).to receive(:monkey_create_derivatives).with "file name"
      }

      it "calls logger.debug and monkey_create_derivatives" do
        expect(Rails.logger).to receive(:debug)
        expect(subject).to receive(:monkey_create_derivatives).with "file name"
        expect(Rails.logger).to receive(:debug).with "Returned from call create_derivatives(file name)"

        subject.create_derivatives "file name"
      end

      skip "Add test for first logger.debug message"
    end

    context "when Exception occurs" do
      before {
        allow(subject).to receive(:monkey_create_derivatives).with("file name").and_raise Exception.new("v. important message")
        allow(Rails.logger).to receive(:error).with "create_derivatives error file name - Exception: v. important message"
      }

      it "catches exception and calls logger.error" do
        expect(Rails.logger).to receive(:debug).with "About to call create_derivatives(file name)"
        expect(subject).to receive(:monkey_create_derivatives).with("file name").and_raise Exception.new("v. important message")
        expect(Rails.logger).to receive(:error).with "create_derivatives error file name - Exception: v. important message"

        expect(Rails.logger).not_to receive(:debug).with "Returned from call create_derivatives(file name)"
        subject.create_derivatives "file name"
      end
    end
  end


  describe "#create_pdf_derivatives" do
    before {
      allow(subject).to receive(:monkey_create_pdf_derivatives).with "file name"
    }
    it "calls monkey_create_pdf_derivatives with filename parameter" do
      expect(subject).to receive(:monkey_create_pdf_derivatives).with "file name"

      subject.create_pdf_derivatives "file name"
    end
  end


  describe "#create_office_document_derivatives" do
    before {
      allow(subject).to receive(:monkey_create_office_document_derivatives).with "file name"
    }
    it "calls monkey_create_office_document_derivatives with filename parameter" do
      expect(subject).to receive(:monkey_create_office_document_derivatives).with "file name"

      subject.create_office_document_derivatives "file name"
    end
  end

end

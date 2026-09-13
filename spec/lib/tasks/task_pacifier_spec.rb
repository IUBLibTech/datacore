require 'rails_helper'
require_relative '../../../lib/tasks/task_pacifier'


RSpec.describe Deepblue::TaskPacifier do

  subject { described_class.new(out: STDOUT, count_nl: 100) }

  describe "#initialize" do
    it "sets instance variables" do
      pacifier = Deepblue::TaskPacifier.new(out: STDOUT, count_nl: 100)

      expect(pacifier.instance_variable_get(:@out)).to eq STDOUT
      expect(pacifier.instance_variable_get(:@count)).to eq 0
      expect(pacifier.instance_variable_get(:@count_nl)).to eq 100
      expect(pacifier.instance_variable_get(:@active)).to eq true
    end
  end


  describe "#active?" do
    it "returns the value of @active" do
      expect(subject.active?).to eq true
    end
  end


  describe "#pacify" do
    context "when @active is false" do
      before {
        subject.instance_variable_set(:@active, false)
      }
      it "returns nil" do
        expect(subject.pacify).to be_nil
      end
    end

    context "when @active is true" do
      before {
        allow(STDOUT).to receive(:flush)
      }

      context "when length of x parameter as string is less than @count_nl" do
        before {
          allow(STDOUT).to receive(:print).with "quixotic"
        }
        it "prints parameter as output and flushes output" do
          expect(STDOUT).to receive(:print).with "quixotic"
          expect(subject).not_to receive(:nl)
          subject.pacify("quixotic")

          expect(subject.instance_variable_get(:@count)).to eq 8
        end
      end

      context "when length of x parameter as string is greater than @count_nl" do
        lorem = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
        before {
          allow(STDOUT).to receive(:print).with lorem
          allow(subject).to receive(:nl)
        }
        it "prints parameter as output, calls nl, and flushes output" do
          expect(STDOUT).to receive(:print).with lorem
          expect(subject).to receive(:nl)
          subject.pacify(lorem)

          expect(subject.instance_variable_get(:@count)).to eq 123
        end
      end

      after {
        expect(STDOUT).to have_received(:flush)
      }
    end
  end


  describe "#pacify_bracket" do
    context "when @active is false" do
      before {
        subject.instance_variable_set(:@active, false)
      }
      it "returns nil" do
        expect(subject.pacify_bracket(nil)).to be_nil
      end
    end

    context "when @active is true" do
      context "when length of x parameter as a string is less than or equal to 1" do
        before {
          allow(subject).to receive(:pacify).with("9")
        }
        it "calls pacify with x parameter withOUT brackets" do
          expect(subject).to receive(:pacify).with("9")

          subject.pacify_bracket(9)
        end
      end

      context "when length of x parameter as a string is greater than 1" do
        before {
          allow(subject).to receive(:pacify).with("{deoxyribonucleic acid}")
        }
        it "calls pacify with x parameter with brackets" do
          expect(subject).to receive(:pacify).with("{deoxyribonucleic acid}")

          subject.pacify_bracket("deoxyribonucleic acid", bracket_open: '{', bracket_close: '}')
        end
      end
    end
  end


  describe "#nl" do
    context "when @active is false" do
      before {
        subject.instance_variable_set(:@active, false)
      }
      it "returns nil" do
        expect(subject.nl).to be_nil
      end
    end

    context "when @active is true" do
      before {
        subject.instance_variable_set(:@count, 55)
        allow(STDOUT).to receive(:print).with("\n")
        allow(STDOUT).to receive(:flush)
      }
      it "prints newline character, flushes output, and sets @count to 0" do
        expect(STDOUT).to receive(:print).with("\n")
        expect(STDOUT).to receive(:flush)

        subject.nl

        expect(subject.instance_variable_get(:@count)).to eq 0
      end
    end
  end


  describe "#reset" do
    context "when @active is false" do
      before {
        subject.instance_variable_set(:@active, false)
      }
      it "returns nil" do
        expect(subject.reset).to be_nil
      end
    end

    context "when @active is true" do
      before {
        subject.instance_variable_set(:@count, 144)
      }
      it "sets @count to 0" do
        subject.reset

        expect(subject.instance_variable_get(:@count)).to eq 0
      end
    end
  end

end

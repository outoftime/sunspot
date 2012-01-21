require File.expand_path('spec_helper', File.dirname(__FILE__))

describe Sunspot::Batcher do
  it "includes Enumerable" do
    described_class.should include Enumerable
  end

  describe "#each" do
    let(:current) { [:foo, :bar] }
    before { subject.stub(:current).and_return current }

    it "iterates over current" do
      yielded_values = []

      subject.each do |value|
        yielded_values << value
      end

      yielded_values.should eq current
    end
  end

  describe "pushing" do
    it "#push pushes to current" do
      subject.push :foo
      subject.current.should include :foo
    end

    it "#<< pushes to current" do
      subject.push :foo
      subject.current.should include :foo
    end
  end


  describe "#current" do
    context "no current" do
      it "starts a new" do
        expect { subject.current }.to change(subject, :depth).by 1
      end

      it "is empty by default" do
        subject.current.should be_empty
      end
    end

    context "with a current" do
      before { subject.start_new }

      it "does not start a new" do
        expect { subject.current }.to_not change(subject, :depth)
      end

      it "returns the same as last time" do
        subject.current.should eq subject.current
      end
    end
  end

  describe "#start_new" do
    it "creates a new batches" do
      expect { 2.times { subject.start_new } }.to change(subject, :depth).by 2
    end

    it "changes current" do
      subject << :foo
      subject.start_new
      subject.should_not include :foo
    end
  end

  describe "#end_current" do
    context "no current batch" do
      it "fails" do
        expect { subject.end_current }.to raise_error Sunspot::Batcher::NoCurrentBatchError
      end
    end

    context "with current batch" do
      before { subject.start_new }

      it "changes current" do
        subject << :foo
        subject.end_current
        subject.should_not include :foo
      end

      it "returns current" do
        subject << :foo
        subject.end_current.should include :foo
      end
    end
  end
end

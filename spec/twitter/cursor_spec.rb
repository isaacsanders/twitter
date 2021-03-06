require 'helper'

describe Twitter::Cursor do

  describe "#collection" do
    it "returns a collection" do
      collection = Twitter::Cursor.new(:ids => [1, 2, 3, 4, 5]).collection
      collection.should be_an Array
      collection.first.should be_a Fixnum
    end
    it "is empty when not set" do
      collection = Twitter::Cursor.new.collection
      collection.should be_empty
    end
  end

  describe "#first?" do
    context "when previous cursor equals zero" do
      before do
        @cursor = Twitter::Cursor.new(:previous_cursor => 0)
      end
      it "returns true" do
        @cursor.first?.should be_true
      end
    end
    context "when previous cursor does not equal zero" do
      before do
        @cursor = Twitter::Cursor.new(:previous_cursor => 1)
      end
      it "returns true" do
        @cursor.first?.should be_false
      end
    end
  end

  describe "#last?" do
    context "when next cursor equals zero" do
      before do
        @cursor = Twitter::Cursor.new(:next_cursor => 0)
      end
      it "returns true" do
        @cursor.last?.should be_true
      end
    end
    context "when next cursor does not equal zero" do
      before do
        @cursor = Twitter::Cursor.new(:next_cursor => 1)
      end
      it "returns false" do
        @cursor.last?.should be_false
      end
    end
  end

end

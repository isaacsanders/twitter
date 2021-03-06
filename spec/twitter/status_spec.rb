require 'helper'

describe Twitter::Status do

  before do
    @old_stderr = $stderr
    $stderr = StringIO.new
  end

  after do
    $stderr = @old_stderr
  end

  describe "#==" do
    it "returns true when objects IDs are the same" do
      status = Twitter::Status.new(:id => 1, :text => "foo")
      other = Twitter::Status.new(:id => 1, :text => "bar")
      (status == other).should be_true
    end
    it "returns false when objects IDs are different" do
      status = Twitter::Status.new(:id => 1)
      other = Twitter::Status.new(:id => 2)
      (status == other).should be_false
    end
    it "returns false when classes are different" do
      status = Twitter::Status.new(:id => 1)
      other = Twitter::Identity.new(:id => 1)
      (status == other).should be_false
    end
  end

  describe "#created_at" do
    it "returns a Time when set" do
      status = Twitter::Status.new(:id => 28669546014, :created_at => "Mon Jul 16 12:59:01 +0000 2007")
      status.created_at.should be_a Time
    end
    it "returns nil when not set" do
      status = Twitter::Status.new(:id => 28669546014)
      status.created_at.should be_nil
    end
  end

  describe "#favoriters_count" do
    it "returns the count of favoriters when favoriters_count is set" do
      status = Twitter::Status.new(:id => 28669546014, :favoriters_count => '1')
      status.favoriters_count.should be_an Integer
      status.favoriters_count.should eq 1
    end
    it "returns nil when not set" do
      status = Twitter::Status.new(:id => 28669546014)
      status.favoriters_count.should be_nil
    end
  end

  describe "#from_user" do
    it "returns a screen name when from_user is set" do
      status = Twitter::Status.new(:id => 28669546014, :from_user => 'sferik')
      status.from_user.should be_a String
      status.from_user.should eq "sferik"
    end
    it "returns a screen name when screen_name is set" do
      status = Twitter::Status.new(:id => 28669546014, :user => {:id => 7505382, :screen_name => 'sferik'})
      status.from_user.should be_a String
      status.from_user.should eq "sferik"
    end
    it "returns nil when not set" do
      status = Twitter::Status.new(:id => 28669546014)
      status.from_user.should be_nil
    end
  end

  describe "#full_text" do
    it "returns the text of a status" do
      status = Twitter::Status.new(:id => 28669546014, :text => 'BOOSH')
      status.full_text.should be_a String
      status.full_text.should eq "BOOSH"
    end
    it "returns the text of a status without a user" do
      status = Twitter::Status.new(:id => 28669546014, :text => 'BOOSH', :retweeted_status => {:id => 28561922517, :text => 'BOOSH'})
      status.full_text.should be_a String
      status.full_text.should eq "BOOSH"
    end
    it "returns the full text of a retweeted status" do
      status = Twitter::Status.new(:id => 28669546014, :retweeted_status => {:id => 28561922516, :text => 'BOOSH', :user => {:id => 7505382, :screen_name => 'sferik'}})
      status.full_text.should be_a String
      status.full_text.should eq "RT @sferik: BOOSH"
    end
    it "returns nil when retweeted_status is not set" do
      status = Twitter::Status.new(:id => 28669546014)
      status.full_text.should be_nil
    end
  end

  describe "#geo" do
    it "returns a Twitter::Geo::Point when set" do
      status = Twitter::Status.new(:id => 28669546014, :geo => {:id => 1, :type => 'Point'})
      status.geo.should be_a Twitter::Geo::Point
    end
    it "returns nil when not set" do
      status = Twitter::Status.new(:id => 28669546014)
      status.geo.should be_nil
    end
  end

  describe "#hashtags" do
    it "returns an Array of Entity::Hashtag when entities are set" do
      hashtags_hash = [
        {
          :text => 'twitter',
          :indices => [10, 33],
        }
      ]
      hashtags = Twitter::Status.new(:id => 28669546014, :entities => {:hashtags => hashtags_hash}).hashtags
      hashtags.should be_an Array
      hashtags.first.should be_a Twitter::Entity::Hashtag
      hashtags.first.indices.should eq [10, 33]
      hashtags.first.text.should eq 'twitter'
    end
    it "is empty when not set" do
      hashtags = Twitter::Status.new(:id => 28669546014).hashtags
      hashtags.should be_empty
    end
    it "warns when not set" do
      Twitter::Status.new(:id => 28669546014).hashtags
      $stderr.string.should =~ /To get hashtags, you must pass `:include_entities => true` when requesting the Twitter::Status\./
    end
  end

  describe "#media" do
    it "returns media" do
      media = Twitter::Status.new(:id => 28669546014, :entities => {:media => [{:id => 1, :type => 'photo'}]}).media
      media.should be_an Array
      media.first.should be_a Twitter::Media::Photo
    end
    it "is empty when not set" do
      media = Twitter::Status.new(:id => 28669546014).media
      media.should be_empty
    end
    it "warns when not set" do
      Twitter::Status.new(:id => 28669546014).media
      $stderr.string.should =~ /To get media, you must pass `:include_entities => true` when requesting the Twitter::Status\./
    end
  end

  describe "#metadata" do
    it "returns a User when user is set" do
      metadata = Twitter::Status.new(:id => 28669546014, :metadata => {}).metadata
      metadata.should be_a Twitter::Metadata
    end
    it "returns nil when user is not set" do
      metadata = Twitter::Status.new(:id => 28669546014).metadata
      metadata.should be_nil
    end
  end

  describe "#oembed" do
    before do
      stub_get("/1/statuses/oembed.json?id=25938088801").
        to_return(:body => fixture("oembed.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      @status = Twitter::Status.new(:id => 25938088801)
    end
    it "requests the correct resource" do
      @status.oembed
      a_get("/1/statuses/oembed.json?id=25938088801").
        should have_been_made
    end
    it "returns an OEmbed instance" do
      oembed = @status.oembed
      oembed.should be_a Twitter::OEmbed
    end
  end

  describe "#place" do
    it "returns a Twitter::Place when set" do
      status = Twitter::Status.new(:id => 28669546014, :place => {:id => "247f43d441defc03"})
      status.place.should be_a Twitter::Place
    end
    it "returns nil when not set" do
      status = Twitter::Status.new(:id => 28669546014)
      status.place.should be_nil
    end
  end

  describe "#repliers_count" do
    it "returns the count of favoriters when repliers_count is set" do
      status = Twitter::Status.new(:id => 28669546014, :repliers_count => '1')
      status.repliers_count.should be_an Integer
      status.repliers_count.should eq 1
    end
    it "returns nil when not set" do
      status = Twitter::Status.new(:id => 28669546014)
      status.repliers_count.should be_nil
    end
  end

  describe "#retweeters_count" do
    it "returns the count of favoriters when retweet_count is set" do
      status = Twitter::Status.new(:id => 28669546014, :retweet_count => '1')
      status.retweeters_count.should be_an Integer
      status.retweeters_count.should eq 1
    end
    it "returns the count of favoriters when retweeters_count is set" do
      status = Twitter::Status.new(:id => 28669546014, :retweeters_count => '1')
      status.retweeters_count.should be_an Integer
      status.retweeters_count.should eq 1
    end
    it "returns nil when not set" do
      status = Twitter::Status.new(:id => 28669546014)
      status.retweeters_count.should be_nil
    end
  end

  describe "#retweeted_status" do
    it "has text when retweeted_status is set" do
      status = Twitter::Status.new(:id => 28669546014, :retweeted_status => {:id => 28561922516, :text => 'BOOSH'})
      status.retweeted_status.should be_a Twitter::Status
      status.retweeted_status.text.should eq 'BOOSH'
    end
    it "returns nil when retweeted_status is not set" do
      status = Twitter::Status.new(:id => 28669546014)
      status.retweeted_status.should be_nil
    end
  end

  describe "#urls" do
    it "returns an Array of Entity::Url when entities are set" do
      urls_hash = [
        {
          :url => 'http://example.com/t.co',
          :expanded_url => 'http://example.com/expanded',
          :display_url => 'example.com/expanded',
          :indices => [10, 33],
        }
      ]
      urls = Twitter::Status.new(:id => 28669546014, :entities => {:urls => urls_hash}).urls
      urls.should be_an Array
      urls.first.should be_a Twitter::Entity::Url
      urls.first.indices.should eq [10, 33]
      urls.first.display_url.should eq 'example.com/expanded'
    end
    it "is empty when not set" do
      urls = Twitter::Status.new(:id => 28669546014).urls
      urls.should be_empty
    end
    it "warns when not set" do
      Twitter::Status.new(:id => 28669546014).urls
      $stderr.string.should =~ /To get urls, you must pass `:include_entities => true` when requesting the Twitter::Status\./
    end
  end

  describe "#user" do
    it "returns a User when user is set" do
      user = Twitter::Status.new(:id => 28669546014, :user => {:id => 7505382}).user
      user.should be_a Twitter::User
    end
    it "returns nil when user is not set" do
      user = Twitter::Status.new(:id => 28669546014).user
      user.should be_nil
    end
    it "has a status when status is set" do
      user = Twitter::Status.new(:id => 28669546014, :text => 'Tweet text.', :user => {:id => 7505382}).user
      user.status.should be_a Twitter::Status
    end
  end

  describe "#user_mentions" do
    it "returns an Array of Entity::UserMention when entities are set" do
      user_mentions_hash = [
        {
          :screen_name => 'sferik',
          :name => 'Erik Michaels-Ober',
          :id_str => '7505382',
          :indices => [0, 6],
          :id => 7505382,
        }
      ]
      user_mentions = Twitter::Status.new(:id => 28669546014, :entities => {:user_mentions => user_mentions_hash}).user_mentions
      user_mentions.should be_an Array
      user_mentions.first.should be_a Twitter::Entity::UserMention
      user_mentions.first.indices.should eq [0, 6]
      user_mentions.first.screen_name.should eq 'sferik'
    end
    it "is empty when not set" do
      user_mentions = Twitter::Status.new(:id => 28669546014).user_mentions
      user_mentions.should be_empty
    end
    it "warns when not set" do
      Twitter::Status.new(:id => 28669546014).user_mentions
      $stderr.string.should =~ /To get user mentions, you must pass `:include_entities => true` when requesting the Twitter::Status\./
    end
  end

end

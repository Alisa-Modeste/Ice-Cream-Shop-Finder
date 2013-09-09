require 'twitter_session'

class Status < ActiveRecord::Base
  #attr_reader :hash
  attr_accessible :body, :twitter_status_id, :user_id
  validates_uniqueness_of :body, :twitter_status_id

  belongs_to(
    :user,
    class_name: "User",
    foreign_key: :twitter_user_id,
    primary_key: :twitter_status_id
  )

  def self.fetch_statuses_for_user(user)
    address = Addressable::URI.new(
      scheme: "https",
      host: "api.twitter.com",
      path: "1.1/statuses/user_timeline.json",
     # query_values: {screen_name: user.twi}
      query_values: {screen_name: user.screen_name}
    ).to_s

    response = TwitterSession.get(address)
    Status.parse_twitter_status(response)
  end

  def self.parse_twitter_status(json_input)
    # get other params
    hashes = JSON.parse(json_input.body)
    statuses = []
    hashes.each do |hash|
      status_hash = { body: hash["text"], twitter_status_id: hash["id"],
        user_id: hash["user"]["id"] }

        result = Status.where("twitter_status_id = ?", hash["id"])
        if result.empty?
          statuses << Status.new(status_hash)
        else
          statuses << result[0]
        end

    end
    statuses
  end

  def self.post(text)
    address = Addressable::URI.new(
      scheme: "https",
      host: "api.twitter.com",
      path: "1.1/statuses/update.json",
      query_values: {status: text}
    ).to_s

    response = TwitterSession.post(address)
    obj = JSON.parse(response.body)
    user_hash = obj["user"]
    local_copy_of_user = User.fetch_by_screen_name(user_hash["screen_name"])
    user = User.new(:screen_name => user_hash["screen_name"],
      :twitter_user_id => user_hash["id"])
    user.save! if local_copy_of_user.nil?

    status = Status.new({twitter_status_id: obj["id"], body: text, user_id:
       user_hash["id"]})
   status.save!
  end


end
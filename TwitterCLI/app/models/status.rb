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


end
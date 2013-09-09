require 'twitter_session'
class User < ActiveRecord::Base
  #attr_reader :hash
  attr_accessible :screen_name, :twitter_user_id
  validates_uniqueness_of :screen_name, :twitter_user_id

  has_many(
    :statuses,
    class_name: "Status",
    foreign_key: :user_id,
    primary_key: :twitter_user_id
  )

  has_many(
    :inbound_follows,
    class_name: "Follow",
    foreign_key: :followee_id,
    primary_key: :twitter_user_id
  )

  has_many(
    :outbound_follows,
    class_name: "Follow",
    foreign_key: :follower_id,
    primary_key: :twitter_user_id
  )

  has_many :followers, through: :inbound_follows, source: :outbound_follows
  has_many :followed_users, through: :outbound_follows, source: :inbound_follows

  def self.fetch_by_screen_name(screen_name)
    # resource url: https://api.twitter.com/1.1/users/lookup.json
    address = Addressable::URI.new(
      scheme: "http", # s?
      host: "api.twitter.com",
      path: "1.1/users/lookup.json",
      query_values: {screen_name: screen_name}
    ).to_s

    response = TwitterSession.get(address)
    self.parse_twitter_params(response)
  end

  def self.parse_twitter_params(json_input)
    hash = JSON.parse(json_input.body)[0]
    user_hash = { screen_name: hash["screen_name"],
              twitter_user_id: hash["id"] }

    result = User.where("twitter_user_id = ?", hash["id"])

    if result.empty?
      User.new(user_hash)
    else
      result[0]
    end

  end

  def self.fetch_by_ids(ids)
    users = []

   # ids.each do |id|


        # ask twitter
        address = Addressable::URI.new(
          scheme: "http", # s?
          host: "api.twitter.com",
          path: "1.1/users/lookup.json",
          query_values: {user_id: ids.join(",")}
        ).to_s

        response = TwitterSession.post(address)
        result = self.parse_twitter_params(response)

        p result
#user = User.where("twitter_user_id = ?", id)
   #   end
    #  users << user
  #  end
  end

  def sync_statuses
    statuses = Status.fetch_statuses_for_user(self)

    statuses.each do |status|
      unless status.persisted?
        status.save!
      end
    end
  end

  def format
   # User.
  end


end
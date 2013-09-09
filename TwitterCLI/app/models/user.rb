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
    self.parse_twitter_params(response)[0]
  end

  def self.parse_twitter_params(json_input)
    hash = JSON.parse(json_input.body)
    users = []
    hash.each do |h|
      p h
      user_hash = { screen_name: h["screen_name"],
                twitter_user_id: h["id"] }

      result = User.where("twitter_user_id = ?", h["id"])

      if result.empty?
        users << User.new(user_hash)
      else
        users << result[0]
      end
    end

    users

  end

  def self.fetch_by_ids(ids)
    users = []

    address = Addressable::URI.new(
      scheme: "http", # s?
      host: "api.twitter.com",
      path: "1.1/users/lookup.json",
      query_values: {user_id: ids.join(",")}
    ).to_s

    response = TwitterSession.post(address)
    result = User.parse_twitter_params(response)

    #p result
  end

  def fetch_followers
    users = []

    address = Addressable::URI.new(
      scheme: "https", # s?
      host: "api.twitter.com",
      path: "1.1/followers/ids.json",
      query_values: {user_id: self.twitter_user_id}
    ).to_s

    p self.twitter_user_id
    response = TwitterSession.get(address)
   # result = User.parse_twitter_params(response)
  s = JSON.parse(response.body)
   p "Respnoe #{s}"
   result = User.fetch_by_ids(s["ids"])
  end

  def sync_statuses
    statuses = Status.fetch_statuses_for_user(self)

    statuses.each do |status|
      unless status.persisted?
        status.save!
      end
    end
  end

  def sync_followers
    followers = self.fetch_followers
    follower_ids = followers.map {|follower| follower.id}
    old_follows = Follow.where("twitter_followee_id = ?", self.twitter_user_id)
    #old_follower_ids = old_follows.map {|old_follow| old_follow.twitter_follower_id}

    followers.each do |follower|
      unless follower.persisted?
        follower.save!
      end
    end

    old_follows.each do |old_follow|
      unless follower_ids.include?(old_follow.twitter_follower_id)
        old_follow.destroy
      end
    end

    follower_ids.each do |follower|
      f = Follow.new(twitter_followee_id: self.twitter_user_id, twitter_follower_id: follower)
      unless f.persisted?
        f.save!
      end
    end

  end


end
class Follow < ActiveRecord::Base
  # belongs_to(
 #  :followee,
 #  class_name: "Follow",
 #  foreign_key: :twitter_followee_id
 #  )
 #
 # has_many(
#  :fo)
#


  belongs_to(
  :follower,
  class_name: "User",
  foreign_key: :twitter_follower_id,
  primary_id: :twitter_user_id
  )

  belongs_to(
  :followee,
  class_name: "User",
  foreign_key: :twitter_followee_id,
  primary_id: :twitter_user_id
  )
end
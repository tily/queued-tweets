require 'twitter'
require 'bson'
require 'mongoid'
require 'timezone'
require './models/user'
require './models/tweet'
Mongoid.load!('./mongoid.yml')

def work
	users = User.all
	users.each do |user|
		timezone = Timezone::Zone.new :zone => 'Asia/Tokyo' # user.time_zone
		time = timezone.time Time.now
		break unless user.hours && user.hours.include?(time.hour)

		twitter = Twitter::REST::Client.new do |config|
			config.consumer_key        = ENV['CONSUMER_KEY']
			config.consumer_secret     = ENV['CONSUMER_SECRET']
			config.access_token        = user.token
			config.access_token_secret = user.secret
		end
		tweets = user.tweets.asc(:created_at).where(published: false).limit(user.times || 5)
		tweets.each do |tweet|
			result = twitter.update(tweet.body)
			tweet.published_at = Time.now
			tweet.published = true
			tweet.status_id = result.id
			tweet.save
		end
	end
end

work

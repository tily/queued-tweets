class User
	include Mongoid::Document
	include Mongoid::Timestamps
	field :screen_name, type: String
	field :uid, type: String
	field :provider, type: String
	field :token, type: String
	field :secret, type: String
	field :hours, type: Array
	field :times, type: Integer
	field :time_zone, type: String
	validates :screen_name, inclusion: {in: ENV['ALLOWED_USERS'].split(/,/)} if ENV['ALLOWED_USERS']
	has_many :tweets
	def self.create_with_omniauth(auth)
		create! do |account|
			account.provider = auth["provider"]
			account.uid = auth["uid"]
			account.screen_name = auth["info"]["nickname"]
			account.token = auth['credentials']['token']
			account.secret = auth['credentials']['secret']
			account.time_zone = auth['extra']['raw_info']['time_zone']
		end
	end
end

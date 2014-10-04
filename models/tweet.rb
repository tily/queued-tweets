class Tweet
	include Mongoid::Document
	include Mongoid::Timestamps
	field :user_id, type: String
	field :body, type: String
	field :published, type: Boolean
	field :published_at, type: Time
	field :status_id, type: Integer
	field :visible, type: Boolean, default: true
	validates :body, length: {maximum: 140}
	belongs_to :user
end

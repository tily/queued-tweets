Bundler.require
require './models/user.rb'
require './models/tweet.rb'

configure do
	enable :sessions
	set :session_secret, ENV['SESSION_SECRET']
	set :haml, ugly: true, escape_html: true
	set :protection, :except => :path_traversal

	use OmniAuth::Builder do
		provider :twitter, ENV['CONSUMER_KEY'], ENV['CONSUMER_SECRET']
	end

	uri = URI.parse(ENV['MONGOHQ_URL'] || 'mongodb://localhost:27017/queued-tweets_development')
	db = uri.path.gsub(/^\//, '')
	connection = Mongo::Connection.new(uri.host, uri.port)
	connection.db(db).authenticate(uri.user, uri.password) unless (uri.user.nil? || uri.password.nil?)
	use Rack::Session::Mongo, :connection => connection, :db => db, :expire_after => 60*60*24*7 # 1 week

	Mongoid.load!("./mongoid.yml")
end

helpers do
	def current_user
		@current_user ||= User.where(uid: session[:uid]).first
	end
end

before do
	pass if request.path_info =~ /^\/auth\//
end

get '/' do
	haml :top
end

post '/' do
	tweet = current_user.tweets.create(
		body: params[:body],
		published: false
	)
	if tweet
		redirect '/'
	else
		haml :top
	end
end

put '/settings' do
	current_user.hours = params['hours'] ? params['hours'].keys.map(&:to_i) : []
	current_user.times = params['times']
	current_user.save
	redirect '/'
end

delete '/:id' do
	tweet = current_user.tweets.find(params[:id])
	tweet.destroy
	redirect '/'
end

get '/auth/twitter/callback' do
	auth = request.env["omniauth.auth"]
	User.where(:provider => auth["provider"], :uid => auth["uid"]).first || User.create_with_omniauth(auth)
	session[:uid] = auth["uid"]
	redirect "http://#{request.env["HTTP_HOST"]}/"
end

get '/logout' do
	session['uid'] = nil
	redirect '/'
end

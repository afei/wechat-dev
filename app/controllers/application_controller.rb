require 'net/http'
require 'digest/sha1'
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
	skip_before_action :verify_authenticity_token

	protected 
	
	def check_signature?
	  Rails.cache.write( "timestamp", params[:timestamp] )
		Rails.cache.write( "nonce", params[:nonce])
		Rails.cache.write( "signature", params[:signature])
	  Digest::SHA1.hexdigest( [params[:timestamp], params[:nonce], ENV['TOKEN']].sort.join ) == params[:signature]
  end
  
	
	def get_access_token
    if Rails.cache.read("access_token").nil?
      uri = URI("https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=#{ENV["APPID"]}&secret=#{ENV["SECRET"]}")
      res = http_get( uri )
			result = JSON.parse( res ) 
      logger.info( result['access_token'] )
      Rails.cache.write("access_token", result['access_token'], expires_in: 7200)
			Rails.cache.read("access_token")
    else
      Rails.cache.read("access_token")
    end
  end
	
  def gen_auth_path origin_path
		"https://open.weixin.qq.com/connect/oauth2/authorize?appid=#{ENV["APPID"]}&redirect_uri=#{ERB::Util.url_encode(origin_path)}&response_type=code&scope=snsapi_userinfo#wechat_redirect"  
	end

	def http_post( url, body )
		uri = URI(url)
		Net::HTTP.start( uri.host, uri.port, use_ssl: uri.scheme == 'https') do |https|
			request = Net::HTTP::Post.new( uri, {'Content-Type'=>'application/json'} )
			request.body = body
			response = https.request  request
			response.body
		end
	end

	def http_get( url )
		uri = URI(url)
		res = Net::HTTP.get_response(uri)
		Rails.logger.info(" http_get " + res.body ) if res.is_a?(Net::HTTPSuccess)
		res.body
	end

end

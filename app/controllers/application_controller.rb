require 'net/http'
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
      res = Net::HTTP.get(uri)
      result = JSON.parse(res)
      logger.info( result['access_token'] )
      Rails.cache.write("access_token", result['access_token'], expires_in: 7200)
    else
      Rails.cache.read("access_token")
    end
  end


end

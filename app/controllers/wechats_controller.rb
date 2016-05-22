require 'digest/sha1'
require 'net/http'
require 'nokogiri'
require 'yaml'
require 'json'
require 'uri'
class WechatsController < ApplicationController
	before_action :check_signature?, only: [:wechat_auth, :wechat_post]

  def wechat_auth
		render plain: params[:echostr]
  end

  def wechat_post
		content = request.body.read.force_encoding("UTF-8")
		Rails.logger.info( content )
		doc = Nokogiri::Slop( content )
    if doc.xml.MsgType.content == "event" and doc.xml.Event.content == "subscribe"
      render "wechats/subscribe", layout: false, :formats => :xml
    else
      render "wechats/message", layout: false, :formats => :xml
    end
  end
	
  def create_menu
		# url = "https://api.weixin.qq.com/cgi-bin/menu/create?access_token=#{get_access_token}"
		menufilepath = Rails.root.join( Rails.root, 'config', "wc_menu.yml" )
		wechatmenu = YAML.load_file( menufilepath )['menu']
		Rails.logger.info( wechatmenu )
		wechatmenu["button"][1]["sub_button"][1]["url"] = gen_auth_path( ( "http://www.afeil.com/members/new/?words=welcome come").encode )
		jsonmenu = JSON.generate( wechatmenu)

		render plain: jsonmenu



	end

	private
	
	def check_signature?
    Digest::SHA1.hexdigest( [params[:timestamp], params[:nonce], @@token].sort.join ) == params[:signature]
	end

	def gen_auth_path origin_path
  "https://open.weixin.qq.com/connect/oauth2/authorize?appid=#{ENV["APPID"]}&redirect_uri=#{origin_path}&response_type=code&scope=snsapi_base#wechat_redirect"  
	end
	
	def get_access_token
		if Rails.cache.read("access_token").nil?
			uri = URI("https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=#{ENV["APPID"]}&secret=#{ENV["SECRET"]}") 
			res = Net::HTTP.get(uri)
			result = JSON.parse(res)
			Rails.logger.info( result["access_token"] )
			Rails.cache.write("access_token", result["access_token"], expires_in: 7200)
		else
			Rails.cache.read("access_token")
		end
	end
	
end

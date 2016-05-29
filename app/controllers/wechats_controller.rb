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
		@doc = Nokogiri::Slop( content )
    if @doc.xml.MsgType.content == "event" and @doc.xml.Event.content == "subscribe"
			@article = Article.find(1)
			render "articles/show", layout: "message_layout", :formats => :xml
    else
      render "wechats/welcome", layout: message, :formats => :xml
    end
  end
	
	def home
	
	end

  def create_menu
		url = "https://api.weixin.qq.com/cgi-bin/menu/create?access_token=#{get_access_token}"
		menufilepath = Rails.root.join( Rails.root, 'config', "wc_menu.yml" )
		wechatmenu = YAML.load_file( menufilepath )['menu']
		Rails.logger.info( wechatmenu )
		wechatmenu["button"][1]["sub_button"][1]["url"] = gen_auth_path( ( "http://www.afeil.com/members/new/?words=welcome come").encode )
		jsonmenu = JSON.generate( wechatmenu)

		Rails.logger.info( "create_menu " + jsonmenu )
		resbody = http_post( url, jsonmenu )
    render "wechats/create_menu", layout: false, json: resbody
	end

	private

	def gen_auth_path origin_path
  "https://open.weixin.qq.com/connect/oauth2/authorize?appid=#{ENV["APPID"]}&redirect_uri=#{origin_path}&response_type=code&scope=snsapi_base#wechat_redirect"  
	end
	
	
end

require 'digest/sha1'
require 'net/http'
require 'nokogiri'

class WechatsController < ApplicationController
	before_action :check_signature?, only: [:wechat_auth, :wechat_post]

  def wechat_auth
		render text: params[:echostr]
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
	
  def wechat_create_menu
	end

	private
	
	def check_signature?
    Digest::SHA1.hexdigest( [params[:timestamp], params[:nonce], @@token].sort.join ) == params[:signature]
	end
	
end

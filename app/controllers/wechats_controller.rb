class WechatsController < ApplicationController
	skip_before_action :verify_authenticity_token
	before_action :check_signature?

  def wechat_auth
  end

  def wechat_post
  end
	
	private
	
	def check_signature?
	end
	
end

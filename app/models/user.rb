class User < ActiveRecord::Base
  has_many :favorites

	# Include default devise modules. Others available are:
	# :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
	devise :database_authenticatable, :registerable, :recoverable, 
				 :rememberable, :trackable, :validatable, :omniauthable

	# Setup accessible (or protected) attributes for your model
	attr_accessible :email, :password, :password_confirmation, :remember_me

	# facebook omniauth code. from https://github.com/plataformatec/devise/wiki/OmniAuth:-Overview
	def self.find_for_facebook_oauth(access_token, signed_in_resource=nil)
		data = access_token.extra.raw_info
		if user = self.find_by_email(data.email)
			user
		else # Create a user with a stub password. 
			self.create!(:email => data.email, :password => Devise.friendly_token[0,20]) 
		end
	end

	def self.new_with_session(params, session)
		super.tap do |user|
			if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
				user.email = data["email"]
			end
		end
	end
end

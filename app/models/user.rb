class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:facebook]
  has_many :comments
  has_many :collects
  has_many :events
  has_many :subjects
  has_many :orders
  has_many :photos
  accepts_nested_attributes_for :photos
  has_many :collect_events ,:through => :collects ,:source =>:event
  def self.from_omniauth(auth)
    # Case 1: Find existing user by facebook uid
    user = User.find_by_fb_uid( auth.uid )
    return user if user

    # Case 2: Find existing user by email
    existing_user = User.find_by_email( auth.info.email )
    if existing_user
      existing_user.fb_uid = auth.uid
      existing_user.fb_token = auth.credentials.token
      existing_user.save!
      return existing_user
    end

    # Case 3: Create new password
    user = User.new
    user.fb_uid = auth.uid
    user.fb_token = auth.credentials.token
    user.email = auth.info.email
    user.image = auth.info.image
    user.name = auth.info.name
    user.password = Devise.friendly_token[0,20]
    user.save!
    return user
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end
end

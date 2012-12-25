class UserProvider < ActiveRecord::Base
  attr_accessible :provider, :uid, :access_token, :token_expires_at
  
  belongs_to :user

  validates_presence_of :provider, :uid, :access_token
  validates_uniqueness_of :uid, scope: :provider

  scope :facebook, where(provider: 'facebook')
  scope :google, where(provider: 'google')

end

class User < ActiveRecord::Base
  has_many :linked_accounts, :dependent => :destroy

  has_secure_password(validations: false)

  validates :email, presence: true, unless: :facebook_user?
  validates :password, presence: true, unless: :facebook_user?
  validates :email, format: {:with => /\A[^@]+@([^@\.]+\.)+[^@\.]+\z/, :message => '^Email is invalid'}, unless: :facebook_user?
  validates :email, uniqueness: {:message => '^Email / password is invalid'}, unless: :facebook_user?

  # validates_confirmation_of :password, :if => :password_present?
  # validates_presence_of     :password, :on => :create, :unless => :facebook_user?

  def self.from_omniauth(auth)
    where(auth.slice(:provider, :uid)).first_or_initialize.tap do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.name = auth.info.name
      user.oauth_token = auth.credentials.token
      user.oauth_expires_at = Time.at(auth.credentials.expires_at)
      user.save!
    end
  end

  def name_or_email
    self.name || self.email
  end

  # private

  def facebook_user?
    provider != nil && uid != nil
  end
end

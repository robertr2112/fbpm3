# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  name                   :string(255)
#  user_name              :string(255)
#  email                  :string(255)
#  admin                  :boolean          default(FALSE)
#  supervisor             :boolean          default(FALSE)
#  password_digest        :string(255)
#  remember_token         :string(255)
#  password_reset_token   :string(255)
#  password_reset_sent_at :datetime
#  confirmed              :boolean          default(FALSE)
#  confirmation_token     :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#

class User < ApplicationRecord
  
  has_many :pool_memberships, dependent: :destroy
  has_many :pools, through: :pool_memberships, dependent: :destroy
  has_many :entries, dependent: :delete_all

  before_save { email.downcase! }
  before_create :create_remember_token

  validates :name,  presence: true, length: { :maximum => 50 }
  validates :user_name,  presence: true, length: { :maximum => 15 },
                    uniqueness: { case_sensitive: false }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 6 }

  has_secure_password

  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def User.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  def send_user_confirm
    self.update_attribute(:confirmation_token, create_token)
    UserMailer.confirm_registration(self).deliver_now
  end

  def send_password_reset
    self.update_attribute(:password_reset_token, create_token)
    self.update_attribute(:password_reset_sent_at, Time.zone.now)
    UserMailer.password_reset(self).deliver_now
  end

  private

    def create_remember_token
      self.remember_token = create_token
    end

    def create_token
      User.encrypt(User.new_remember_token)
    end

end

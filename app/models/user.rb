# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  name            :string
#  email           :string
#  image_url       :string
#  password_digest :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  role_id         :integer
#

class User < ApplicationRecord

  has_secure_password

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  
  validates :name,  presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  validates :password, presence: true, length: { minimum: 8 }

  before_create :confirmation_token
  before_validation :assign_default_role, unless: -> (model) { model.role_id }

  delegate :name, to: :role, prefix: true

  belongs_to :role
  has_many :social_auths, dependent: :destroy
  has_many :projects, inverse_of: :user, dependent: :destroy
  has_one :draft_project, -> { where(approved: false) }, class_name: 'Project'

  def assign_default_role
    role = Role.find_by_name("donor")
    self.role = role
  end

  def update_user_role_to_creator
    return if(self.role_name == 'creator') 
    role = Role.find_by_name('creator')
    self.update_column(:role_id, role.id)
  end


  def self.from_auth(params, current_user)
    params = params.with_indifferent_access
    socialAuth = SocialAuth.find_or_initialize_by(provider: params[:provider], uid: params[:uid])
    if socialAuth.persisted?
      if current_user
        if current_user.id == socialAuth.user.id
          user = current_user
        else
          return false
        end
      else
        user = socialAuth.user
      end
    else
      if current_user
        user = current_user
      elsif params[:email].present?
        user = User.find_or_initialize_by(email: params[:email])
      else
        user = User.new
      end
    end

    socialAuth.secret = params[:secret]
    socialAuth.token  = params[:token]
    fallback_name        = params[:name].split(" ") if params[:name]
    fallback_first_name  = fallback_name.try(:first)
    fallback_last_name   = fallback_name.try(:last)

    first_name    ||= (params[:first_name] || fallback_first_name)
    last_name     ||= (params[:last_name]  || fallback_last_name)
    
    user.name = "#{first_name} #{last_name}"

    user.password = SecureRandom.urlsafe_base64.to_s if user.password_digest.blank?
    
    if user.image_url.blank?
      user.image_url = params[:image_url]
    end

    if user.email.blank?
      user.save(validate: false)
    else
      user.save
    end
    socialAuth.user_id ||= user.id
    socialAuth.save
    user
  end

  def email_activate
    self.email_confirmed = true
    self.confirm_token = nil
    save!(:validate => false)
  end


  private
  
  def confirmation_token
    if self.confirm_token.blank?
      self.confirm_token = SecureRandom.urlsafe_base64.to_s
    end
  end

end

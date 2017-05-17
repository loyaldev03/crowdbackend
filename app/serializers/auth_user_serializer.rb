# == Schema Information
#
# Table name: users
#
#  id                  :integer          not null, primary key
#  name                :string
#  email               :string
#  image_url           :string
#  password_digest     :string
#  email_confirmed     :boolean          default(FALSE)
#  confirm_token       :string
#  role_id             :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  secondary_email     :string
#  facebook_url        :string
#  twitter_url         :string
#  instagram_url       :string
#  google_plus_url     :string
#  phone_no            :string
#  total_backed_amount :integer          default(0)
#  stripe_user_id      :string

class AuthUserSerializer < ActiveModel::Serializer
  attributes :id, :name, :image_url, :email, :notifications_count, :stripe_user_id
  
  def image_url
    return object.image_url if object.image_url
    return "http://lh3.googleusercontent.com/-XdUIqdMkCWA/AAAAAAAAAAI/AAAAAAAAAAA/4252rscbv5M/photo.jpg"
  end

  def notifications_count
    object.notifications.where(read_status: false).count
  end

end

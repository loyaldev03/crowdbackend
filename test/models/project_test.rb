# == Schema Information
#
# Table name: projects
#
#  id             :integer          not null, primary key
#  title          :string
#  category_id    :integer
#  user_id        :integer
#  image_url      :string
#  video_url      :string
#  pledged_amount :integer
#  funded_amount  :integer
#  funding_model  :string
#  start_date     :datetime
#  duration       :integer
#  approved       :boolean          default(FALSE)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

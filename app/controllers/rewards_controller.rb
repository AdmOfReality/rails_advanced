class RewardsController < ApplicationController
  before_action :authenticate_user!

  def index
    @rewards = current_user.rewards.includes(:question, image_attachment: :blob)
  end
end

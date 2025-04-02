class WalletsController < ApplicationController
  before_action :authenticate_user!

  def show
    @wallet = current_user.wallet
  end
end

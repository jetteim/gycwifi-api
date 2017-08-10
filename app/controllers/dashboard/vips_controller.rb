class Dashboard::VipsController < ApplicationController
  def index
    @vips = Vip.all
    respond_with @vips
  end
end

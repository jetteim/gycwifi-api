require 'csv'
class Dashboard::SocialLogsController < ApplicationController
  # include Skylight::Helpers
  before_action :parse_params

  BOM = "\xEF\xBB\xBF".freeze
  PAGESIZE = 50

  def index
    locations = @str_prms[:location_id] ? [@str_prms[:location_id]] : policy_scope(Location).pluck(:id)
    res = SocialLog.authorizations(locations).order(id: :desc).all.page(@page).per(@itemsOnPage)
    items_count = SocialLog.authorizations(locations).pluck(:id).count
    social_logs = res.to_a
    render json: {
      data: {
        itemsOnPage: PAGESIZE,
        social_logs: social_logs,
        items_count: items_count
      },
      status: 'ok',
      message: 'Social accounts'
    }
  end

  def parse_params
    itemsOnPage = @str_prms[:itemsOnPage] || PAGESIZE
    @itemsOnPage = itemsOnPage.to_i
    page = @str_prms[:page] || 1
    @page = page.to_i
    @page = 1 if @page < 1
  end
end

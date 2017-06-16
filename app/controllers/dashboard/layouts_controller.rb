class Dashboard::LayoutsController < ApplicationController
  include Skylight::Helpers
  before_action :get_layout, only: %i[show update destroy]

  def index
    layouts = @str_prms[:brand_id] ? [Brand.find_by(id: @str_prms[:brand_id]).layout] : policy_scope(Layout)
    render json: {
      data: { layouts: layouts }, status: 'ok', message: 'Layouts list'
    }
  end

  def show
    render json: { data: { layout: @layout }, status: 'ok', message: 'Layout' }
  end

  def create
    layout = Layout.new(layout_params)
    if layout.save
      render json: {
        data: nil, status: 'ok', message: I18n.t('errors.layouts.created')
      }
    else
      render json: {
        data: nil, status: 'error', message: I18n.t('errors.no_access')
      }
    end
  end

  def update
    RedisCache.flush('layout', @layout.id)
    if @layout.update brand_params
      render json: {
        data: nil, status: 'ok', message: I18n.t('errors.layouts.updated')
      }
    else
      render json: {
        data: nil, status: 'error', message: I18n.t('errors.no_access')
      }
    end
  end

  def destroy
    RedisCache.flush('layout', @layout.id)
    if @layout.destroy
      render json: {
        data: nil, status: 'ok', message: I18n.t('errors.layouts.deleted')
      }
    else
      render json: {
        data: nil, status: 'error', message: I18n.t('errors.no_access')
      }
    end
  end

  private

  def get_layout
    @layout = Layout.find(@str_prms[:id])
  end

  def layout_params
    paramsю.require(:layout).permit(:title, :css, :local_path)
  end
end

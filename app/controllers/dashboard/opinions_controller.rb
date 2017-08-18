class Dashboard::OpinionsController < ApplicationController
  before_action :get_opinion, only: %i[show destroy update]
  wrap_parameters Opinion, format: [:json]

  def index
    authorize Opinion
    opinions = policy_scope(Opinion)
    render json: {
      data: opinions.as_json,
      status: 'ok',
      message: 'User opinions'
    }
  end

  def show
    authorize @opinion
    render json: {
      data: @opinion.as_json,
      status: 'ok',
      message: 'User opinion'
    }
  end

  def create
    opinion = Opinion.new(params[:opinion])
    opinion.user_id = @current_user.id
    authorize(Opinion)
    if opinion.save
      render json: {
        data: { opinion: opinion.as_json },
        status: 'ok',
        message: 'Opinion saved'
      }
    else
      render json: { data: nil, status: 'error', message: 'Error' }
    end
  end

  def update
    authorize @opinion
    return render json: { status: 'error', message: @opinion.errors } unless @opinion.update(params[:opinion])
    render json: {
        data: { opinion: @opinion.reload.as_json },
        status: 'ok',
        message: 'Opinion updated'
      }
  end

  def destroy
    authorize @opinion
    if @opinion.destroy
      render json: {
        data: nil,
        status: 'ok',
        message: 'Opinion deleted'
      }
    else
      render json: {
        data: nil,
        status: 'error',
        message: 'Error'
      }
    end
  end

  def opinion_rating
    render json: {
      data: { answers_total: Opinion.all.pluck(:id).count, average_rating: 4 },
      status: 'ok',
      message: 'Opinion saved'
    }
  end

  private

  def get_opinion
    @opinion = Opinion.find(@str_prms[:id])
  end
end

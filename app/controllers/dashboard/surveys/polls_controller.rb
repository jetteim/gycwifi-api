module Dashboard
  module Surveys
    # Создание и обработка опросов
    class PollsController < ApplicationController
      include Skylight::Helpers

      instrument_method
      def index
        return raise_not_authorized(Poll) unless RedisCache.cached_policy(current_user, Poll, 'index')
        polls = Location.find_by(id: @str_prms[:location_id]) ? policy_scope(Poll).where(location: location) : policy_scope(Poll).reverse
        render json: {
          data: {
            polls: polls.as_json,
            items_count: polls.pluck(:id).count,
            can_create: RedisCache.cached_policy(@current_user, Poll, 'create')
          },
          status: 'ok',
          message: 'Polls list'
        }
      end

      instrument_method
      def show
        poll = Poll.includes(questions: { answers: { attempts: :client } }).find(@str_prms[:id])
        return raise_not_authorized(poll) unless RedisCache.cached_policy(@current_user, poll, 'show')
        result = poll.as_json(
          include: [questions: {
            include: [answers: {
              include: [attempts: { include: [:client] }],
              methods: [:attempts_count]
            }]
          }]
        )
        render json: {
          data: {
            poll: result,
            status: 'ok',
            message: 'Poll data'
          }
        }
      end

      instrument_method
      def create
        return raise_not_authorized(Poll) unless RedisCache.cached_policy(@current_user, Poll, 'create')
        poll = Poll.create(title: poll_params[:title], user_id: @current_user[:id])
        @str_prms[:questions].each do |question_from_params|
          question = Question.create(
            title: question_from_params[:title],
            question_type: question_from_params[:question_type],
            poll_id: poll.id
          )

          question_from_params[:answers].each do |answer|
            Answer.create(title: answer[:title], custom: answer[:custom], question_id: question.id)
          end
        end

        render json: {
          data: { poll: poll.as_json },
          status: 'ok',
          message: I18n.t('errors.polls.created')
        }
      end

      instrument_method
      def update
        poll = Poll.find(@str_prms[:id])
        return raise_not_authorized(poll) unless RedisCache.cached_policy(@current_user, poll, 'update')
        # Update poll
        poll.update(title: poll_params[:title], run_once: poll_params[:run_once])
        poll.questions.delete_all # => all question answers deleted automatically
        # Update questions and answers
        @str_prms[:questions].each do |question_from_params|
          question = Question.create(
            title: question_from_params[:title],
            question_type: question_from_params[:question_type],
            poll_id: poll.id
          )

          question_from_params[:answers].each do |answer|
            Answer.create(title: answer[:title], custom: answer[:custom], question_id: question.id)
          end
        end

        render json: {
          data: { poll: poll.as_json },
          status: 'ok',
          message: I18n.t('errors.polls.updated')
        }
      end

      instrument_method
      def destroy
        poll = Poll.find(@str_prms[:id])
        return raise_not_authorized(poll) unless RedisCache.cached_policy(@current_user, poll, 'destroy')
        if poll.destroy
          render json: {
            data: nil,
            status: 'ok',
            message: I18n.t('errors.polls.deleted')
          }
        else
          render json: {
            data: nil,
            status: 'error',
            message: I18n.t('errors.no_access')
          }
        end
      end

      instrument_method
      def export_to_xlsx
        @statistic = PollStatistic::QuestionService.new(Poll.find(@str_prms[:poll_id])).call.to_xlsx
        send_data(
          Base64.encode64(@statistic[:file]),
          type: @statistic[:type],
          filename: @statistic[:filename],
          stream: false
        )
      end

      private

      def poll_params
        params.require(:poll).permit(:title, :user_id, :run_once)
      end

      instrument_method
      def normalize_params
        params.permit!
        @str_prms = eval(params.as_json.to_s.gsub(/\"(\w+)\"(?==>)/, ':\1'))
        @str_prms[:questions] = [JSON.parse!(@str_prms[:questions], symbolize_names: true)] if @str_prms[:questions].is_a?(String)
        logger.info "normalized params #{@str_prms.inspect}".cyan
      end
    end
  end
end

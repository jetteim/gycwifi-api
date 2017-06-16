module Dashboard
  module Surveys
    # Получаем статистику по клиентам относительно текущего Опроса
    class StatsController < ApplicationController
      # GET polls/:poll_id/:answer_id/clients
      before_action :set_poll
      def clients
        # Poll -> Questions -> Answers -> Attempts -> Clients
        # @p = Poll.includes(questions: { answers: { attempts: { client: :social_accounts } } })
        #          .where('answers.id = ?', @str_prms[:answer_id])
        #          .where(id: @poll.id)
        # render json:  @p.as_json(include: {
        #                            questions: {
        #                              include: {
        #                                answers: {
        #                                  include: {
        #                                    attempts: {
        #                                      include: {
        #                                        client: {
        #                                          include: [:social_accounts]
        #                                        }
        #                                      }
        #                                    }
        #                                  }
        #                                }
        #                              }
        #                            }
        #                          })
      end

      # private

      # def set_poll
      #   id = @str_prms[:poll_id] || @str_prms[:id]
      #   @poll = Poll.find(id)
      #   return raise_not_authorized(poll) unless RedisCache.cached_policy(current_user, @poll, 'show')
      # end
    end
  end
end

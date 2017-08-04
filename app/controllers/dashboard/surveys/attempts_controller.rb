module Dashboard
  module Surveys
    class AttemptsController < ApplicationController
      include Skylight::Helpers

      skip_before_action :authenticate_user
      REPLY_OK = {
        data: nil,
        status: 'ok',
        message: 'Thank you for your answer!'
      }.freeze

      instrument_method
      def create
        # Создаём объединяющий объект с уникальным номером
        interview_uuid = SecureRandom.uuid
        return render json: REPLY_OK unless questions = @str_prms[:questions]
        questions.each do |question|
          # Перебираем все полученные ответы
          next unless (answers = question[:answers])
          # Перебираем все полученные ответы на вопросы...
          answers.each do |answer|
            # ...и создаём Attempt
            next unless answer
            Attempt.create(
              client_id:      @str_prms[:client_id],
              answer_id:      answer[:id],
              interview_uuid:   interview_uuid,
              custom_answer:  answer[:custom_answer]
            )
          end
        end
        render json: REPLY_OK
      end

      instrument_method
      def normalize_params
        binding.pry
        super
        @str_prms[:questions] = [JSON.parse!(@str_prms[:questions], symbolize_names: true)] if @str_prms[:questions].is_a?(String)
        logger.info "normalized params #{@str_prms.inspect}".cyan
      end
    end
  end
end

# Attempt
#
# interview
# poll_id
# client_id
# question_id
# answer_id
#
# POST "/attempts"  for 193.104.234.42  at 2017-04-12 16:06:13 +0300
# Processing by Dashboard::Surveys::AttemptsController # create as JSON
# Parameters =
#   { 'poll_id' => 2,
#     'questions' =>
#     [
#       { 'id' => 3,
#         'answers' => [{ 'id' => 1 }],
#         'question_type' => 'radio' },
#       { 'id' => 4,
#         'answers' => [
#           { 'id' => 3 }, { 'id' => 4 }
#         ],
#         'question_type' => 'checkbox' }
#     ],
#
#     'attempt' => {
#       'poll_id' => 2,
#       'questions' => [
#         { 'id' => 3,
#           'answers' =>
#             [
#               { 'id' => 1 }
#             ],
#           'question_type' => 'radio' },
#         { 'id' => 4,
#           'answers' => [
#             { 'id' => 3 },
#             { 'id' => 4 }
#           ],
#           'question_type' => 'checkbox' }
#       ]
#     } }

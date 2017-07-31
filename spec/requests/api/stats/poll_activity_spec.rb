require 'rails_helper'

RSpec.shared_examples 'valid_poll_statistic' do |ago, now, range, format|
  def date_range(start, finish, period, format)
    (start.to_date..finish.to_date).map{|date| date.send("beginning_of_#{period}").strftime(format)}.uniq
  end

  it 'return valid statistic' do
      labels = date_range(ago, now, range, format)
      expect(parsed_response[:data].size).to eq(1)
      expect(parsed_response[:data][0].size).to eq(2)
      expect(parsed_response[:data][0][0]).to include(labels: [answer.title, 'Свой ответ'],
                                                      data: [ 2, 0 ],
                                                      type: 'pie',
                                                      title: question.title,
                                                      name: 'question_pie')
      expect(parsed_response[:data][0][0][:attempts].size).to eq(answer.attempts.count)
      expect(parsed_response[:data][0][0][:attempts][0]).to include(phone_number: first_attempt.client.phone_number,
                                                                    answer: first_attempt.answer.title,
                                                                    avatar: nil)
      expect(parsed_response[:data][0][1]).to eq({ labels: labels,
                                                   data: [ [1] + [0] * (labels.size - 2) + [1] ],
                                                   attempts: 2,
                                                   autorizations: 1,
                                                   type: 'line',
                                                   name: 'question_activity_line' })
  end
end

RSpec.describe 'Polls activity', type: :request do
  context '/stats/poll_activity' do
    let(:user) { create(:user) }
    let(:poll) { create(:poll, :with_attempt, user: user, created_at: 1.year.ago) }
    let(:question) {poll.questions.first}
    let(:answer) {question.answers.first}
    let!(:location) {create(:location, :with_social_log, poll: poll)}
    let(:first_attempt) { answer.attempts.first }
    context 'return formatted polls activity for more then 3 month' do
      before do
        create(:attempt, answer: answer, created_at: 120.days.ago)
        get my_uri("stats/poll_activity?id=#{poll.id}"), headers: {'Authorization' => token(user)}
      end
      include_examples 'valid_poll_statistic', 120.days.ago, Time.zone.now, 'month', '%Y-%m'
    end
    context 'return formatted polls activity for more less 3 month and more then 1 month' do
      before do
        create(:attempt, answer: answer, created_at: (90.days.ago))
        get my_uri("stats/poll_activity?id=#{poll.id}"), headers: {'Authorization' => token(user)}
      end
      include_examples 'valid_poll_statistic', 90.days.ago, Time.zone.now, 'week', '%F'
    end
    context 'return formatted polls activity for less then 1 month' do
      before do
        create(:attempt, answer: answer, created_at: (30.days.ago))
        get my_uri("stats/poll_activity?id=#{poll.id}"), headers: {'Authorization' => token(user)}
      end
      include_examples 'valid_poll_statistic', 30.days.ago, Time.zone.now, 'day', '%F'
    end
  end
end


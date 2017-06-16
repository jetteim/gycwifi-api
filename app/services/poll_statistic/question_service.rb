module PollStatistic
  class QuestionService < BaseService
    attr_reader :data

    def call
      @data ||=  Question.includes(attempts: {client: :social_accounts}).where('poll_id = ?', @poll.id).map do |q|
        answers = q.answers.to_a.select { |answer| answer.custom == false }
        result = { title: q.title }
        result[:labels] = answers.map(&:title)
        result[:data] = answers.map do |answer|
          q.attempts.select { |attempt| attempt.custom_answer.nil? && attempt.answer_id == answer.id }.size
        end
        result[:labels] << 'Свой ответ'
        result[:data] <<  q.attempts.select { |attempt| attempt.custom_answer.present? }.size
        result[:attempts] = q.attempts.map do |attempt|
          avatar = attempt.client&.social_accounts&.find{ |account| account.image.present? }&.image
          {
            attempt_date: attempt.created_at,
            phone_number: attempt.client&.phone_number,
            answer: (attempt.custom_answer || attempt.answer.title),
            avatar: avatar
          }
        end
        result
      end
      self
    end

    def to_xlsx
      {
        file: generate_xslx(@data).read,
        type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        filename:  "poll##{@poll.id}.xlsx"
      }
    end

    def to_pie
      @data.map do |question|
        question.merge!(type: 'pie', name: 'question_pie')
      end
    end

    def generate_xslx(data)
      package = Axlsx::Package.new do |p|
        data.each_with_index do |question, num|
          table_size = question[:labels].size
          p.workbook.add_worksheet(name: "Вопрос ##{num}") do |sheet|
            style = sheet.styles.add_style(bg_color: '02CC20', fg_color: '000000')
            sheet.add_row ['Вопрос:', question[:title]], style: style
            sheet.add_row %w[Ответ Количество]
            question[:data].size.times do |index|
              sheet.add_row [question[:labels][index], question[:data][index]]
            end
            sheet.add_chart(Axlsx::Pie3DChart, start_at: [0, question[:labels].size + 3], end_at: [6, table_size + 18], title: question[:title]) do |chart|
              chart.add_series data: sheet["B3:B#{question[:data].size + 2}"],
                               labels: sheet["A3:A#{question[:data].size + 2}"],
                               colors: %w[FF0000 00FF00 0000FF 00FFFF FF00FF FFFF00]
            end
            (table_size + 15).times { sheet.add_row [] }
            sheet.add_row ['Дата Ответа', 'Телефон ответившего', 'Ответ'], style: style
            question[:attempts].each do |attempt|
              sheet.add_row [attempt[:attempt_date], attempt[:phone_number], attempt[:answer]]
            end
          end
        end
      end
      package.to_stream
    end

    # def zip_files(files)
    #   zip = Zip::OutputStream.write_buffer do |stream|
    #     files.each_with_index do |file, index|
    #       stream.put_next_entry("question-#{index + 1}.xlsx")
    #       xlsx_tempfile = Tempfile.new("question#{index}")
    #       xlsx_tempfile.write(file.read) && xlsx_tempfile.rewind
    #       stream.write IO.read(xlsx_tempfile.path)
    #       xlsx_tempfile.close!
    #     end
    #   end
    #   zip.rewind && zip.read
    # end
  end
end

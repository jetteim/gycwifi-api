module JsonHelper
  def parsed_response
    # reparse_and_never_memoize_as_response_may_change
    ->() { JSON.parse(response.body, symbolize_names: true) }.call
  end

  def json_request_headers
    { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
  end
end
#
# RSpec.configure do |config|
#   config.include JsonHelper, type: :request
# end

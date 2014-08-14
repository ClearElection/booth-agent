module ResponseJson
  def response_json
    @response_json ||= JSON.parse(response.body)
  end
end

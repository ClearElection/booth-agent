module ResponseJson
  def response_json
    @response_json ||= JSON.parse(response.body) unless response.body.blank?
  end

  def response_error_message
    @response_error_message ||=
      case
      when response_json.nil? then nil
      when String === (err = response_json["error"]) then err
      when Hash == err then err["message"]
      when !(errs = @response_json["errors"]).blank? then errs.map(&its["message"]).join('; ')
      end
  end
end

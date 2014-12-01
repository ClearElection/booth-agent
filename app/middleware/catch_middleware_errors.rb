class CatchMiddlewareErrors
  def initialize(app)
    @app = app
  end

  def call(env)
    begin
      @app.call(env)
    rescue Committee::InvalidRequest => error
      return [
          400, { "Content-Type" => "application/json" },
          [ { status: 400, error: error.message }.to_json ]
        ]
    end
  end
end

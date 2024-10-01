class Request::BadRequestError < Request::HttpBaseError
  def initialize(message)
    super(400, message)
  end
end
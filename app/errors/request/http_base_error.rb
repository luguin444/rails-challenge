class Request::HttpBaseError < StandardError
  attr_reader :message, :status
  
  def initialize(status, message)
    @message = message
    @status = status
    super(message)
  end
end
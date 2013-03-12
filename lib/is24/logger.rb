require 'logger'

module Is24
  module Logger
    def logger(msg)
      @logger = ::Logger.new(STDOUT)
      @logger.info msg
    end
  end
end

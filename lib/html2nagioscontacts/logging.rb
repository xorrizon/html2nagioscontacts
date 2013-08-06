
module Html2nagioscontacts
  module Logging
    extend self
    def logger
      @logger ||= Logger.new STDOUT
    end
  end
end



require "logger"

require "html2nagioscontacts/version"
require "html2nagioscontacts/settings"
require "html2nagioscontacts/parser"
require "html2nagioscontacts/nagios"

module Html2nagioscontacts
  def self.logger
    @logger ||= Logger.new STDOUT
  end
end

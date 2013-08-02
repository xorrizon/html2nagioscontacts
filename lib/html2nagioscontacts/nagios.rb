require "nagios_config"

module Html2nagioscontacts
  class Nagios
    DISALLOWED_CHARS = /[\\~!$%&*"|'<>?,()={}\^]/i
    DISALLOWED_CHARS_NAME = /\W/i

    # returns a NagiosConfig::Config object
    def create_contacts(source)
      builder = NagiosConfig::Builder.new
      source.each do |c|
        builder.define "Contact" do |contact|
          contact.use = 'generic-contact'
          contact.contact_name = c['name']
          contact.alias = c['alias']
          contact.email = c['email']
        end
      end
      builder.root
    end

    # Make sure there are no string literals which are forbidden in a nagios config object
    def prepare_source(source)
      source.each do |c|
        c['email'].gsub! DISALLOWED_CHARS, ''
        c['email'].gsub! /\s/, ''
        c['alias'] = c['name'].gsub DISALLOWED_CHARS, '_'
        c['name'] = c['alias'].gsub DISALLOWED_CHARS_NAME, ''
      end
      source
    end

  end
end
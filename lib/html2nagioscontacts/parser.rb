require "cgi"
require "open-uri"

module Html2nagioscontacts

  class Parser
    HTMLTAG_REGEX=/<.*?>/i
    EMAIL_REGEX=/.+[@].+[.].+/i
    attr_writer :url, :text

    def parse
      raise "url or text must be set" if @url.nil? && @text.nil?

      load_url unless @url.nil?

      raise "Got no input" if @text.nil?

      data = [ @text.dup ]
      Settings.parser['rules'].each_with_index do |rule, index|
        data.flatten!
        if index < Settings.parser['rules'].size-1
          data.map! do |d|
            next if d.nil?
            match = d.scan rule
          end
        else
          data.map! do |d|
            next if d.nil?
            match = d.scan rule
            if match.nil? || match.empty?
              nil
            else
              contacts = []
              match.each do |m|
                next if m.nil? || !m.instance_of?(Array) || m.size < 2
                name = remove_html_and_parse_entities m[0]
                email = remove_html_and_parse_entities m[1]
                if name =~ EMAIL_REGEX && !(email =~ EMAIL_REGEX)
                  name, email = email, name
                end
                next unless email =~ EMAIL_REGEX
                contacts << {'name' => name, 'email' => email}
              end
              contacts
            end
          end
        end
      end

      data.flatten!
      data = data.delete_if {|d| d.nil?}
      data
    end

    def remove_html_and_parse_entities(text)
      result = text.gsub HTMLTAG_REGEX, ''
      CGI::unescape_html(result).strip
    end

    def load_url
      params = {}
      if Settings.parser['use_auth'] == true
        params = {:http_basic_authentication => [ Settings.parser['auth_user'], Settings.parser['auth_pass'] ]}
      end

      open(@url, params) do |f|
        @text = f.read
      end

    end

  end
end

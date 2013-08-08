
module Html2nagioscontacts
  class Main
    include Logging

    def usage
      puts <<-EOS
  USAGE: #{File.basename(__FILE__)} configfile
    configfile: The path to the config file
                A default configfile you can use as a template is
                located at: #{File.expand_path(File.join( File.dirname(__FILE__), '../lib/html2nagioscontacts/default_config.yml' ))}
      EOS
    end

    def run(args)
      if args.length != 1
        usage
        return 1
      end

      configfile = args.shift

      unless File.exists? configfile
        logger.error 'Config file does not exist'
        return 2
      end

      begin
        Settings.load! configfile
      rescue Exception => e
        logger.fatal "Couldn't load settings: " + e.message
        return 3
      end

      begin

        parser = Parser.new
        parser.url = Settings.parser['url']
        results = parser.parse

        nagios = Nagios.new
        nagios.prepare_source(results)
        contacts = nagios.create_contacts results

        output = nagios.contacts2string(contacts)
        output_old = ""
        if File.exists?(Settings.generated_contacts_path)
          output_old = File.read(Settings.generated_contacts_path)
        end

        if output.gsub(/#.*?$/, '') == output_old.gsub(/#.*?$/, '')
          logger.info 'Nothing changed in config file, exiting'
          return 0
        end

        File.write Settings.generated_contacts_path, output
        logger.info 'Wrote config file'

        return 0 unless Settings.restart_nagios_after_update

        out = `#{Settings.commands['check_nagios_config']}`
        if $?.success?
          logger.info 'Nagios config check passed'
        else
          logger.error 'Nagios config check failed!'
          logger.error out
          return 4
        end

        out = `#{Settings.commands['restart_nagios']}`
        if $?.success?
          logger.info 'Nagios restarted'
        else
          logger.error 'Nagios restart failed'
          logger.error out
          return 5
        end

      rescue Exception => e
        logger.fatal 'An unhandled error occurred: ' + e.message
        logger.fatal e.backtrace.join("\n")
        return 42
      end
    end

  end
end
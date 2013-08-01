# inspired by http://speakmy.name/2011/05/29/simple-configuration-for-ruby-apps/
require 'yaml'

module Html2nagioscontacts

  module Settings
    # again - it's a singleton, thus implemented as a self-extended module
    extend self

    attr_reader :_settings

    def load_default
      @_settings = {}
      load!(File.join(File.dirname(__FILE__), 'default_config.yml'))
    end


    # This is the main point of entry - we call Settings.load! and provide
    # a name of the file to read as it's argument.
    def load!(filename)
      newsets = YAML::load_file(filename)
      deep_merge!(@_settings, newsets)
    end

    # Deep merging of hashes
    # deep_merge by Stefan Rusterholz, see http://www.ruby-forum.com/topic/142809
    def deep_merge!(target, data)
      merger = proc{|key, v1, v2|
        Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
      target.merge! data, &merger
    end

    def method_missing(name, *args, &block)
      @_settings[name.to_s] ||
          fail(NoMethodError, "unknown configuration root #{name}", caller)
    end

    load_default if @_settings.nil?

  end

end


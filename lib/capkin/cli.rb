module Capkin
  # Capking Command Line
  class CLI
    # Using class methods
    class << self
      #
      # Check config file
      #
      def check_capkin_file
        return if File.exist?('Capkin')
        puts Paint['Creating Capkin file...', :red]
        FileUtils.cp File.join(File.dirname(__FILE__), 'Capkin'), '.'
        puts Paint['Config file `Capkin` created, edit and re-run.', :green]
        exit
      end

      def read_file
        @config = YAML.load_file('Capkin')
        msg = "Config file OK! '#{@config['app']}' -> #{@config['name']}"
        puts Paint[msg, :green]
      end

      def work!(params)
        check_capkin_file
        read_file
        Capkin::Robot.new(@config, params).upload_apk!
      end
    end
  end
end

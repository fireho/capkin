module Capkin
  #
  # class that does IO operations.
  #
  class Project

    def initialize
      check_capkin_file
    end
    
    #
    # Check config file
    #
    def check_capkin_file
      return if File.exist?('Capkin')
      puts Paint['Creating Capkin file...', :red]
      FileUtils.cp File.join(File.dirname(__FILE__), 'Capkin'), '.'
      puts Paint['✓ Config file `Capkin` created, edit and re-run.', :green]
      exit
    end

    def read_capkin_file
      @config = YAML.load_file('Capkin')
      msg = "✓ Config file OK! '#{@config['app']}'"
      puts Paint[msg, :green]
      return @config
    end


  #End class
  end
end

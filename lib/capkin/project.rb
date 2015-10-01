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
      @config
    end

    #
    # Write the Apk info to file
    #
    def write_edit_info_to_file(info)
      # serialized = YAML::dump(info)
      File.open('ApkInfo', 'w') do |file|
        file.write("title: #{info.title} \n")
        file.write("language: #{info.language} \n")
        file.write("short_description: #{info.short_description} \n")
        file.write("full_description: |+\n #{info.full_description.gsub("\n", "\n  ")}")
      end

      msg = 'ApkInfo was written, edit and run `capkin update_info` to sync :)'
      puts Paint[msg, :green]
    end

    def read_apk_info
      if File.exist?('ApkInfo')
        @info = YAML.load_file('ApkInfo')
        puts Paint['Apk Info loaded!', :green]
        return @info
      else
        puts Paint['ApkInfo not found, run `capkin get_info` to create it', :red]
        exit
      end
    end
  end # Project
end # Capkin

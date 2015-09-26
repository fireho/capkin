module Capkin
  # Capking Command Line
  class CLI
    # Using class methods
    class << self

      def work!(params)

        project = Capkin::Project.new

        config = project.read_capkin_file

        robot = Capkin::Robot.new(config, params)

        case params.join
        when 'list' then robot.list
        when 'info' then robot.info_apk
        when 'edit_info' then robot.edit_info
        else
          robot.upload_apk!
        end
      end
    end
  end
end

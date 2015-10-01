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
        when 'show_info' then robot.info_apk
        when 'update_info' then
          info = project.read_apk_info
          robot.edit_info(info)
        when 'get_info' then
          info = robot.get_info_apk
          project.write_edit_info_to_file(info)
        else
          robot.upload_apk!
        end
      end
    end
  end
end

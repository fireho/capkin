require 'pry'
require 'yaml'
require 'paint'
require 'fileutils'

require 'googleauth'
require 'google/apis/androidpublisher_v2'

# Capkin. Uploading your apks since 2015!
module Capkin
  autoload :CLI, 'capkin/cli'
  autoload :Robot, 'capkin/robot'
end

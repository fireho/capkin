module Capkin
  class CLI

    def self.check_capkin_file
      unless File.exist?('Capkin')
        puts 'Creating Capkin File'
        FileUtils.cp File.dirname(__FILE__) + '/Capkin', '.'
        exit
      end
    end

    def self.read_file
      @config = YAML.load_file('Capkin')
      puts @config
    end

    def self.upload_apk
      #get the authorization
      scopes = ['https://www.googleapis.com/auth/androidpublisher']
      auth = Google::Auth.get_application_default(scopes)

      headers = {
        'access_token'=> ENV['CAPKIN_CLIENT']
      }

      auth.apply(headers)

      pkg_name = @config['name']
      source = @config['build'] + pkg_name + '.apk'
      # create a publisher object
      publisher = Google::Apis::AndroidpublisherV2::AndroidPublisherService.new
      publisher.authorization = auth

      # start a new edit
      edit = publisher.insert_edit(pkg_name)

      # upload the APK
      apk = publisher.upload_apk(pkg_name, edit.id, upload_source: source)

      # update the alpha track to point to this APK
      track = publisher.get_track(pkg_name, edit_id, 'alpha')
      track.update!(version_codes: [ apk.version_code ]) # you need to use a track object to change this
      publisher.update_track(pkg_name, edit_id, 'production', track) # save the modified track object

      # commit the edit
      publisher.commit_edit(pkg_name, edit_id)
    end

    def self.work!(params)
      check_capkin_file
      read_file
      upload_apk
    end
  end


end

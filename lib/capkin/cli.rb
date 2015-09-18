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
        puts 'Creating Capkin File'
        FileUtils.cp File.dirname(__FILE__) + '/Capkin', '.'
        exit
      end

      def read_file
        @config = YAML.load_file('Capkin')
        puts @attr = config
      end

      # To be refactored in robot.rb
      def upload_apk
        # Get package
        app = @config['name']
        source = @config['build'] + app + '.apk'

        # create a publisher object
        pub = Google::Apis::AndroidpublisherV2::AndroidPublisherService.new

        # Oauth2
        # grant_type=authorization_token|refresh_token
        # code=
        # client_id=<the client ID token created in the APIs Console>
        # client_secret=<the client secret corresponding to the client ID>
        # refresh_token=<the refresh token from the previous step>
        # start a new edit
        headers = {
          'access_token' => ENV['CAPKIN_CLIENT']
        }

        # Get authorization!
        scopes = ['https://www.googleapis.com/auth/androidpublisher']
        auth = Google::Auth.get_application_default(scopes)
        auth.apply(headers)

        pub.authorization = auth
        edit = pub.insert_edit(app)

        # upload the APK
        apk = pub.upload_apk(app, edit.id, upload_source: source)

        # update the alpha track to point to this APK
        track = pub.get_track(app, edit_id, 'alpha')

        # you need to use a track object to change this
        track.update!(version_codes: [apk.version_code])

        # save the modified track object
        pub.update_track(app, edit_id, 'production', track)

        # commit the edit
        pub.commit_edit(app, edit_id)
      end

      def self.work!(params)
        check_capkin_file
        read_file
        upload_apk
      end
    end
  end
end

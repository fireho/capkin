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
        puts Paint["Config file OK! APP: '#{@config['app']}'", :green]
      end

      # To be refactored in robot.rb
      def upload_apk
        # Get package
        app = @config['name']
        source = @config['build'] + app + '.apk'

        puts Paint["Publishing new APK: ./#{source} to 'Play'", :green]

        # create a publisher object
        pub = Google::Apis::AndroidpublisherV2::AndroidPublisherService.new

        # Get authorization!
        scopes = ['https://www.googleapis.com/auth/androidpublisher']
        auth = Google::Auth.get_application_default(scopes)

        # Oauth2
        # grant_type=authorization_token|refresh_token
        # code=
        # client_id=<the client ID token created in the APIs Console>
        # client_secret=<the client secret corresponding to the client ID>
        # refresh_token=<the refresh token from the previous step>
        # start a new edit
        # headers = {
        #   'access_token' => ENV['CAPKIN_CLIENT']
        # }
        # auth.apply(headers)
        pub.authorization = auth

        # Create new edition
        edit = pub.insert_edit(app)

        # upload the APK
        apk = pub.upload_apk(app, edit.id, upload_source: source)

        # Update the alpha track to point to this APK
        track = pub.get_track(app, edit_id, 'alpha')

        # You need to use a track object to change this
        track.update!(version_codes: [apk.version_code])

        # Save the modified track object
        pub.update_track(app, edit_id, 'production', track)

        # Commit the edit
        pub.commit_edit(app, edit_id)

        puts 'DONE'
      end

      def work!(params)
        check_capkin_file
        read_file
        upload_apk
      end
    end
  end
end

module Capkin
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
  class Robot
    SCOPE = ['https://www.googleapis.com/auth/androidpublisher']
    attr_reader :apk, :app, :pub, :pkg, :stage, :track, :source

    def initialize(config, stage = 'alpha')
      @app = config['app']
      @pkg = config['name']
      @source ||= File.join(config['build'], "#{@app}.apk")
      @stage = stage

      # Get authorization!
      @auth = Google::Auth.get_application_default(SCOPE)
      # create a publisher object
      @pub = Google::Apis::AndroidpublisherV2::AndroidPublisherService.new
      @pub.authorization = @auth
    end

    # Create new edition
    def edit
      @edit ||= pub.insert_edit(pkg)
    end

    def upload_apk!
      puts Paint["Publishing new APK: ./#{source} to 'Play'", :blue]
      # upload the APK
      @apk = pub.upload_apk(pkg, edit.id, upload_source: source)
      puts Paint["APK uploaded #{apk.version_code}", :yellow]
      track!
    end

    def track!
      # Update the alpha track to point to this APK
      @track = pub.get_track(pkg, edit.id, stage)

      # You need to use a track object to change this
      track.update!(version_codes: [apk.version_code])
      commit!
    end

    def commit!
      # Save the modified track object
      pub.update_track(pkg, edit.id, stage, track)

      # Commit the edit
      pub.commit_edit(pkg, edit.id)
    end
  end
end

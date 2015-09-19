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
  #
  # https://developers.google.com/android-publisher/api-ref/edits
  #
  # https://github.com/google/google-api-ruby-client/issues/140
  #
  class Robot
    SCOPE = ['https://www.googleapis.com/auth/androidpublisher']
    STAGE = 'alpha'
    attr_reader :apk, :app, :pub, :pkg, :stage, :track, :source

    def initialize(config, stage = nil)
      @app = config['app']
      @pkg = config['name']
      @source ||= File.join(config['build'], "#{@app}.apk")
      stage = stage.join if stage.respond_to?(:join)
      @stage = stage.strip.empty? ? STAGE : stage.strip

      init_google
      puts Paint["Publishing new APK: ./#{source} ➔ '#{@stage}'", :blue]
    end

    def init_google
      # Get authorization!
      @auth = Google::Auth.get_application_default(SCOPE)
      # create a publisher object
      @pub = Google::Apis::AndroidpublisherV2::AndroidPublisherService.new
      @pub.authorization = @auth
    end

    # Create new editio
    def edit
      @edit ||= pub.insert_edit(pkg)
    end

    def track
      @track ||= pub.get_track(pkg, edit.id, stage)
    end

    # Uploads the APK
    def upload_apk!
      @apk = pub.upload_apk(pkg, edit.id, upload_source: source)
      puts Paint["✓ APK uploaded! ##{apk.version_code}", :green]
      track!
      puts Paint["✓ All done! ##{apk.inspect}", :green]
    rescue Google::Apis::ClientError => e
      if e.to_s =~ /apkUpgradeVersionConflict/
        puts Paint['✓ Version already exists on play store!', :yellow]
      else
        puts Paint["✗ Problem with upload: #{e}", :red]
        raise e
      end
    end

    # Update the alpha track to point to this APK
    # You need to use a track object to change this
    def track!
      puts Paint["Pushing APK ➔ '#{track.track}'", :blue]
      track.update!(version_codes: [apk.version_code])

      # Save the modified track object
      pub.update_track(pkg, edit.id, stage, track)

      commit!
    end

    # Commit the edit
    def commit!
      pub.commit_edit(pkg, edit.id)
    rescue Google::Apis::ClientError => e
      puts Paint["✗ Problem commiting: #{e}", :red]
      raise e
    end
  end
end

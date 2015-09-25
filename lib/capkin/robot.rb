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
      @source ||= File.join(config['build'], "#{@app}.apk")
      stage = stage.join if stage.respond_to?(:join)
      @stage = stage.strip.empty? ? STAGE : stage.strip

      @pkg = namespace
      init_google
    end

    def init_google
      # Get authorization!
      @auth = Google::Auth.get_application_default(SCOPE)
      # Create a publisher object
      @pub = Google::Apis::AndroidpublisherV2::AndroidPublisherService.new
      @pub.authorization = @auth
    end

    # Create new edition
    def edit
      @edit ||= pub.insert_edit(pkg)
    end

    def track
      @track ||= pub.get_track(pkg, edit.id, stage)
    end

    def subject # the apk
      @current_apk ||= Android::Apk.new(source)
    end

    def app_name
      subject.manifest.label
    end

    def namespace
      subject.manifest.package_name
    end

    # show the current version about your apk.
    def current_version
      subject.manifest.version_code
    end

    # show the creation date of your apk.
    def apk_date
      subject.time.strftime('%Y-%m-%d')
    end

    #
    #
    # pub.list_listings ->  Info about the app
    # def all_listings ??

    #
    # pub.list_apks     ->  Lists with idcode and sha1
    def list
      puts "➔ Listing all APK! Current #{current_version} - #{apk_date}"
      versions = verify_versions
      versions.each do |a|
        color = current_version == a.version_code ? :green : :black
        puts Paint["#{a.version_code} ➔ #{a.binary.sha1}", color]
      end
    end

    def verify_versions
      list_apks = pub.list_apks(pkg, edit.id)
      return list_apks.apks
    end

    #
    # Show the play store info about your apk.
    #
    def info
      a = pub.get_listing(pkg, edit.id, 'pt-BR')
      puts "\n#{a.title} - #{a.short_description}"
      puts '---'
      puts a.full_description
      puts
    end

    #
    # Edit the apk info!
    def edit_info
      puts Paint["Editing the info about: #{namespace}", :blue]

      # Create a Listing object
      puts "Enter new title: "
      title = $stdin.gets.chomp

      puts "Enter the short description: "
      short_description = $stdin.gets.chomp

      puts "Enter the full description: "
      full_description = $stdin.gets.chomp

      listing = Google::Apis::AndroidpublisherV2::Listing.new
      listing.full_description = full_description
      listing.short_description = short_description
      listing.title = title

      # Dispacth the info
      list = pub.update_listing(pkg, edit.id, "pt-BR", listing)

      # Commit the changes
      commit!
      puts Paint["Alterações realizadas :)", :green]

    end

    # Uploads the APK
    def upload_apk!
      verify_apk_before_upload

      @apk = pub.upload_apk(pkg, edit.id, upload_source: source)

      track!

      puts Paint["✓ APK uploaded! ##{apk.version_code}", :green]
    rescue Google::Apis::ClientError => e
      if e.to_s =~ /apkUpgradeVersionConflict/
        puts Paint['✓ Version already exists on play store!', :yellow]
      else
        puts Paint["✗ Problem with upload: #{e}", :red]
        raise e
      end
    end

    # Verify if the version apk already existis on Play store
    def verify_apk_before_upload
      play_store_apks = verify_versions
      apk_exists = false

      play_store_apks.each do |apk|
        apk_exists = current_version == apk.version_code ? "true" : "false"

        if apk_exists
          puts Paint["The apk already uploaded to Play Store!", :red]
          exit
        end
      end
    end

    # Update the alpha track to point to this APK
    # You need to use a track object to change this
    def track!
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

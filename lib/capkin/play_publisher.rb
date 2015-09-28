module Capkin

  #
  # Class that does the access on Google play
  #
  class PlayPublisher
    SCOPE = ['https://www.googleapis.com/auth/androidpublisher']
    attr_reader :apk, :app, :pub, :pkg, :stage, :track, :source

    def initialize(app, source, stage)

      @app = app
      @source = source
      @stage = stage

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

    def edit
      @edit ||= pub.insert_edit(pkg)
    end

    def get_track(pkg, edit_id, stage)
      @track ||= @pub.get_track(pkg, edit_id, stage)
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
    def list_apks
      list = pub.list_apks(pkg, edit.id)
      return list.apks
    end

    #
    # Show the play store info about your apk.
    #
    def info_apk
      apk = pub.get_listing(pkg, edit.id, 'pt-BR')
      return apk
    end

    #
    # Edit the apk info!
    def edit_info(listing)
      # Dispacth the info
      pub.update_listing(pkg, edit.id, listing.language, listing)

      # Commit the changes
      commit!
    end

   # Uploads the APK
   def upload_apk!
     puts Paint["Publishing new APK: ➔ Apk: #{@app} Stage: '#{@stage}'", :blue]
     verify_apk_before_upload

     @apk = pub.upload_apk(pkg, edit.id, upload_source: source)
     track!
   end

   # Verify if the version apk already existis on Play store
  def verify_apk_before_upload
    apk_exists = false

    list_apks.each do |apk|
      if current_version == apk.version_code
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

  # End class
  end
end

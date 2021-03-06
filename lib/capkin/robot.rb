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
  # http://www.rubydoc.info/github/google/google-api-ruby-client/Google/Apis/AndroidpublisherV2/AndroidPublisherService
  class Robot
    STAGE = 'alpha'
    attr_reader :apk, :app, :publisher, :pkg, :stage, :track, :source

    def initialize(config, stage = nil)
      app = config['app']
      source ||= File.join(config['build'], "#{app}.apk")
      stage = stage.join if stage.respond_to?(:join)
      @stage = stage.strip.empty? ? STAGE : stage.strip

      # @pkg = namespace
      @publisher = Capkin::PlayPublisher.new(app, source, stage)
    end

    # List the published apks
    def list
      puts "➔ Listing all APK! Current #{publisher.current_version} - #{publisher.apk_date}"
      versions = publisher.list_apks
      versions.each do |a|
        color = publisher.current_version == a.version_code ? :green : :black
        puts Paint["#{a.version_code} ➔ #{a.binary.sha1}", color]
      end
    end

    #
    # Show the play store info about your apk.
    #
    def info_apk
      a = publisher.info_apk
      puts "\n#{a.title} - #{a.short_description}"
      puts '---'
      puts a.full_description
      puts
    end

    def get_info_apk
      publisher.info_apk
    end

    #
    # Edit the apk info!
    def edit_info(info)
      puts Paint["Editing the info about: #{publisher.namespace}", :blue]

      listing = Google::Apis::AndroidpublisherV2::Listing.new
      listing.full_description = info['full_description']
      listing.short_description = info['short_description']
      listing.title = info['title']
      listing.language = info['language']

      publisher.edit_info(listing)

      puts Paint['Alterações realizadas :)', :green]
    end

    # Uploads the APK
    def upload_apk!
      publisher.upload_apk!

      puts Paint['✓ APK uploaded!', :green]
    rescue Google::Apis::ClientError => e
      if e.to_s =~ /apkUpgradeVersionConflict/
        puts Paint['✓ Version already exists on play store!', :yellow]
      else
        puts Paint["✗ Problem with upload: #{e}", :red]
        raise e
      end
    end
  end # Robot
end # Capkin

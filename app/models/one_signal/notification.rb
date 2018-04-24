require('httparty')

module OneSignal
  class Notification
    include HTTParty
    base_uri "https://onesignal.com/api/v1/notifications"

    attr_accessor :options

    def initialize(options = {})
      @options = options
    end

    def self.create(options = {})
      item = new(options)
      item
    end

    def push_now
      Rails.logger.debug "Start: Start pushing notification"
      body = {
        app_id: ENV["ONE_SIGNAL_APP_ID"],
        contents: { "en" => options[:description] || "" },
        headings: { "en" => options[:title] || "" },
        subtitle: { "en" => options[:subtitle] || "" },
        data: options[:data],
        big_picture: options[:big_picture],
        small_icon: "ic_neta_cap",
        android_accent_color: "ff745df1",
        android_led_color: "ff745df1"
      }
      if options.key?(:filters)
        body[:filters] = options[:filters]
      elsif options.key?(:included_segments)
        body[:included_segments] = options[:included_segments]
      end
      if Rails.env.test?
        body
      else
        response = self.class.post('',
                                   body: body.to_json,
                                   headers: {
                                     'Content-Type' => 'application/json',
                                     'Authorization' => "Basic #{ENV['ONE_SIGNAL_API_KEY']}"
                                   })
        body = JSON.parse(response.body)
        Rails.logger.debug "Recevied response from one signal #{body}"
        Rails.logger.debug "End: Pushing notification"
      end
    end
  end
end

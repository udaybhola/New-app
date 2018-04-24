# {
#   "dynamicLinkInfo": {
#     "dynamicLinkDomain": string,
#     "link": string,
#     "androidInfo": {
#       "androidPackageName": string,
#       "androidFallbackLink": string,
#       "androidMinPackageVersionCode": string,
#       "androidLink": string
#     },
#     "iosInfo": {
#       "iosBundleId": string,
#       "iosFallbackLink": string,
#       "iosCustomScheme": string,
#       "iosIpadFallbackLink": string,
#       "iosIpadBundleId": string,
#       "iosAppStoreId": string
#     },
#     "navigationInfo": {
#       "enableForcedRedirect": boolean,
#     },
#     "analyticsInfo": {
#       "googlePlayAnalytics": {
#         "utmSource": string,
#         "utmMedium": string,
#         "utmCampaign": string,
#         "utmTerm": string,
#         "utmContent": string,
#         "gclid": string
#       },
#       "itunesConnectAnalytics": {
#         "at": string,
#         "ct": string,
#         "mt": string,
#         "pt": string
#       }
#     },
#     "socialMetaTagInfo": {
#       "socialTitle": string,
#       "socialDescription": string,
#       "socialImageLink": string
#     }
#   },
#   "suffix": {
#     "option": "SHORT" or "UNGUESSABLE"
#   }
# }

require('httparty')

module Firebase
  class DynamicLink
    include ActiveModel::AttributeMethods
    include HTTParty
    base_uri "https://firebasedynamiclinks.googleapis.com/v1/shortLinks?key=#{ENV['FIREBASE_API_KEY']}"

    attr_accessor :title, :description, :image_url, :link

    def initialize(options = {})
      @title = options[:title]
      @description = options[:description]
      @image_url = options[:image_url]
      @link = options[:link]
    end

    def generate
      deployment_type = ENV['DEPLOYMENT_TYPE']
      androidPackageName = "in.netaapp"
      case deployment_type
      when "local"
        androidPackageName = "in.netaapp.debug"
      when "dev"
        androidPackageName = "in.netaapp.dev"
      end
      body = {
        "dynamicLinkInfo": {
          "dynamicLinkDomain": ENV['FIREBASE_DYNAMIC_LINK_DOMAIN'],
          "link": @link,
          "androidInfo": {
            "androidPackageName": androidPackageName
          },
          "iosInfo": {
            "iosBundleId": "",
            "iosFallbackLink": "",
            "iosCustomScheme": "",
            "iosIpadFallbackLink": "",
            "iosIpadBundleId": "",
            "iosAppStoreId": ""
          },
          "navigationInfo": {
            "enableForcedRedirect": true
          },
          "socialMetaTagInfo": {
            "socialTitle": @title,
            "socialDescription": @description,
            "socialImageLink": @image_url
          }
        },
        "suffix": {
          "option": "UNGUESSABLE"
        }
      }
      unless Rails.env.test?
        response = self.class.post('', body: body.to_json, headers: { 'Content-Type' => 'application/json' })
        body = JSON.parse(response.body)
        if response.code == 200
          shortLink = body["shortLink"]
          [shortLink, body]
        else
          logger.error "Failed generating link #{body}"
          [nil, body]
        end
      end
    end
  end
end

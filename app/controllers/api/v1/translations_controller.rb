module Api
  module V1
    class TranslationsController < ApiV1Controller
      def index
        language = params.permit(:language)[:language] || 'English'
        translations = LanguageLabel.all.select do |label|
          label.translations.key?(language)
        end
        @translations = translations.map { |item| [item.translations["Key"], item.translations[language] || ""] }
      end

      def available_languages
        @languages = Language.available
      end
    end
  end
end

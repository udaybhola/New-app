class LanguageLabel < ApplicationRecord
  default_scope { order('key ASC') }

  def self.create_from_csv_row(translations = {})
    key = translations["Key"]
    label = LanguageLabel.find_or_create_by(key: key.parameterize)
    label.update_attributes(translations: translations.to_h)
  end
end

class CssHexColorValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    # unless value.match?(/^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/i)

    unless value.match?(/^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/i) # alternatve for pre Ruby 2.4 versions
      object.errors[attribute] << (options[:message] || "must be a valid CSS hex color code")
    end
  end
end

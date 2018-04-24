module DeploymentTypeHelper
  extend ActiveSupport::Concern
  SUPPORTED_ENV = %w[local dev staging production production_latest].freeze

  def deployment_type
    ENV["DEPLOYMENT_TYPE"]
  end

  def raise_if_no_deployment_type!
    unless Rails.env.test?
      raise "DEPLOYMENT_TYPE variable is not defined" if ENV["DEPLOYMENT_TYPE"].blank?
      raise "DEPLOYMENT_TYPE variable should be one of #{SUPPORTED_ENV}" unless SUPPORTED_ENV.include? ENV["DEPLOYMENT_TYPE"]
    end
  end

  SUPPORTED_ENV.each do |item|
    define_method "is_#{item}_deployment?".to_sym do
      ENV["DEPLOYMENT_TYPE"] == item
    end
  end
end

include DeploymentTypeHelper
raise_if_no_deployment_type!

if Rails.env.test?
  url = 'http://localhost:3000'
else
  if is_local_deployment?
    url = 'http://localhost:3000'
  elsif is_dev_deployment?
    url = 'https://neta-dev.herokuapp.com'
  elsif is_production_deployment?
    url = 'https://www.neta-app.com'
  end
end
Rails.application.routes.default_url_options[:host] = ENV['DEFAULT_HOST_URL'] || url

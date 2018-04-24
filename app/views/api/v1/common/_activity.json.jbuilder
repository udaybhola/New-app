json.extract! activity, :activity_id, :action, :actions, :resource, :voted_poll_option_id, :created_at, :score
json.data activity.data, partial: 'api/v1/common/post', as: :post

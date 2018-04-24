class PushNotificationJob < ApplicationJob
  queue_as :default

  def perform(notifiable)
    Rails.logger.debug "Start: Notifiation job for resource with id"
    case notifiable[:type]
    when 'Poll'
      poll = Poll.find(notifiable[:id])
      options = {
        description: poll.question,
        data: {
          resource_id: poll.id,
          resource_type: 'poll'
        }
      }
      image_url = poll.image_url
      options[:big_picture] = image_url unless image_url.blank?

      if poll.admin?
        if poll.national_level?
          options[:title] = "A new national level poll is available"
          options[:subtitle] = "National Level"
          options[:data][:poll_level] = "national"
          options[:included_segments] = 'All'
        end
        #   elsif poll.state_level?
        #     options[:title] = "A new state level poll is available in #{poll.region&.name&.titleize}"
        #     options[:subtitle] = "State Level"
        #     options[:data][:poll_level] = "state"
        #     options[:filters] = [
        #       { "field": "tag", "key": "state_id", "relation": "=", "value": poll.region&.id }
        #     ]
        #   elsif poll.constituency_level?
        #     options[:title] = "A new constituency level poll is available in #{poll.region&.name}"
        #     options[:subtitle] = "Constituency Level"
        #     options[:data][:poll_level] = "state"
        #     options[:filters] = [
        #       { "field": "tag", "key": "ac_id", "relation": "=", "value": poll.region&.id }
        #     ]
        #   end
        # else
        #   title = "New poll in your constituency"
        #   subtitle = "Posted in #{poll.region&.name&.titleize}"
        #   title = if poll.is_anonymous?
        #             "New anonymous poll posted"
        #           else
        #             "New poll posted by #{poll&.user&.notification_name}"
        #           end
        #   options[:title] = title
        #   options[:subtitle] = subtitle
        #   options[:data][:poll_level] = "constituency"
        #   options[:filters] = [
        #     { "field": "tag", "key": "ac_id", "relation": "=", "value": poll.region&.id },
        #     { "field": "tag", "key": "user_id", "relation": "!=", "value": poll.user&.id }
        #   ]
      end

      unless options[:title].nil?
        notification = OneSignal::Notification.create(options)
        notification.push_now
      end
    when 'Issue'
      issue = Issue.find(notifiable[:id])
      options = {
        description: issue.title,
        data: {
          resource_id: issue.id,
          resource_type: 'issue'
        }
      }
      image_url = issue.image_url
      options[:big_picture] = image_url unless image_url.blank?

      # unless issue.admin?
      #
      #   title = "A new issue is available in your constituency"
      #   subtitle = "Posted in #{issue.region&.name&.titleize}"
      #   title = if issue.is_anonymous?
      #             "New anonymous issue posted"
      #           else
      #             "New issue posted by #{issue.user&.notification_name}"
      #           end
      #   options[:title] = title
      #   options[:subtitle] = subtitle
      #   options[:data][:issue_level] = "constituency"
      #   options[:filters] = [
      #     { "field": "tag", "key": "ac_id", "relation": "=", "value": issue.region&.id },
      #     { "field": "tag", "key": "user_id", "relation": "!=", "value": issue.user&.id }
      #   ]
      #   notification = OneSignal::Notification.create(options)
      #   notification.push_now
      # end
      if issue.national_level?
        options[:title] = "A new national level issue is available"
        options[:subtitle] = "National Level"
        options[:data][:poll_level] = "national"
        options[:included_segments] = 'All'
      end

      unless options[:title].nil?
        notification = OneSignal::Notification.create(options)
        notification.push_now
      end
      # when 'Comment'
      # when 'Like'
    end
    Rails.logger.debug "End: Need to perform activity job #{notifiable}"
  end
end

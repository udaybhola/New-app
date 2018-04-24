require 'rails_helper'

RSpec.describe PushNotificationJob, type: :job do
  # before(:each) do
  #   ActiveJob::Base.queue_adapter = :test
  # end

  # after(:each) do
  #   ActiveJob::Base.queue_adapter = :inline
  # end

  # it "should queue a push notification job when like is created" do
  #   like = create(:like)
  #   expect(PushNotificationJob).to have_been_enqueued.exactly(:once).with(id: like.id, type: 'Like').on_queue("default")
  # end

  # it "should queue a push notification job when comment is created" do
  #   comment = create(:comment)
  #   expect(PushNotificationJob).to have_been_enqueued.exactly(:once).with(id: comment.id, type: 'Comment').on_queue("default")
  # end

  # it "should queue a push notification job when poll is created" do
  #   post = create(:poll)
  #   expect(PushNotificationJob).to have_been_enqueued.exactly(:once).with(id: post.id, type: 'Poll').on_queue("default")
  # end

  # it "should queue a push notification job when issue is created" do
  #   post = create(:issue)
  #   expect(PushNotificationJob).to have_been_enqueued.exactly(:once).with(id: post.id, type: 'Issue').on_queue("default")
  # end
end

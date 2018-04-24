module Likeable
  extend ActiveSupport::Concern

  included do
    has_many :likes, as: :likeable, dependent: :destroy
  end

  def like(user)
    like = Like.new(user: user, likeable: self)
    like.save!
    like
  end

  def unlike(user)
    like = likes.find_by(user: user)
    like.destroy
    like
  end
end

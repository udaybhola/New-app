module ScoreCalculator
  ## calculates the score of post based on no of commetns and likes, will be used to show trending posts
  def calculate_post_value(no_of_comments, no_of_likes)
    no_of_comments + no_of_likes
  end

  def calcualate_comment_value(no_of_replies, no_of_likes)
    no_of_replies + no_of_likes
  end
end

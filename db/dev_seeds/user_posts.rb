constituency = Constituency.first
category = Category.first
user = User.first

issues = [
  {
    title: "Aadhar Linking is not mandatory issue",
    description: "Government is strong arming this thing for their benifit"
  },
  {
    title: "What is Lorem Ipsum?",
    description: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum."
  },
  {
    title: "Why do we use Lorem Ipsum?",
    description: "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for 'lorem ipsum' will uncover many web sites still in their infancy. Various versions have evolved over the years, sometimes by accident, sometimes on purpose (injected humour and the like).",
    anonymous: true
  },
  {
    title: "Where can I get some Lorem Ipsum",
    description: "There are many variations of passages of Lorem Ipsum available, but the majority have suffered alteration in some form, by injected humour, or randomised words which don't look even slightly believable. If you are going to use a passage of Lorem Ipsum, you need to be sure there isn't anything embarrassing hidden in the middle of text. All the Lorem Ipsum generators on the Internet tend to repeat predefined chunks as necessary, making this the first true generator on the Internet. It uses a dictionary of over 200 Latin words, combined with a handful of model sentence structures, to generate Lorem Ipsum which looks reasonable. The generated Lorem Ipsum is therefore always free from repetition, injected humour, or non-characteristic words etc."
  },
  {
    title: "Where does Lorem Ipsum come from",
    description: "Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source",
    anonymous: true
  }
]

polls = [
  {
    question: "What do you think contributed to win of bjp?",
    poll_options: ["Patidars shifting Allegience", "Modis campaign", "Congress leaders unnecessary comments"]
  },
  {
    question: "Who do you think will win next general Elections?",
    poll_options: ["Congress", "BJP", "Third Front"]
  },
  {
    question: "Who do you think will influence results most in the next Andhra polls",
    poll_options: ["Pavan Kalyan", "Chandrababu Naidu", "Jagan Mohan Reddy"]
  },
  {
    question: "Whats the most important issue which should be present in manifesto of every party in next General Party",
    poll_options: ["Free Education for BPL", "Free Food for BPL", "Free House for BPL", "Free Biryani for BPL", "Free Toilet for BPL"]
  }
]

issues.each do |issue|
  title = issue[:title]
  description = issue[:description]
  anonymous = issue[:anonymous] || false
  p "creating issue: #{title}"
  Issue.find_or_create_by(constituency: constituency, category: category, title: title, description: description, user: user, anonymous: anonymous)
end

polls.each do |poll|
  question = poll[:question]
  poll_options = poll[:poll_options]
  p "creating poll: #{question}"
  user_poll = Poll.find_or_create_by(constituency: constituency, category: category, question: question, user: user)
  poll_options.each do |option|
    user_poll.poll_options.build(answer: option)
  end
  user_poll.save!
end

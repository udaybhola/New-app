p "creating candidates...."
candidates = [
  {
    email: 'neta1@neta.com',
    name: 'neta1',
    phone: '1231231231'
  },
  {
    email: 'neta2@neta.com',
    name: 'neta2',
    phone: '1231231230'
  },
  {
    email: 'neta3@neta.com',
    name: 'neta3',
    phone: '1231231232'
  }
]

candidates.each do |candidate|
  email = candidate[:email]
  name = candidate[:name]
  phone = candidate[:phone]
  user = User.find_or_create_by(email: email, name: name, phone_number: phone)
  profile = user.profile
  new_candidate = Candidate.new(phone_number: phone)
  new_candidate.profile = profile
  new_candidate.save!
end

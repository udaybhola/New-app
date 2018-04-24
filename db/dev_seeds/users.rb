religions = Religion.all.map(&:name)
castes = Caste.all.map(&:name)
professions = Profession.all.map(&:name)
education_levels = Education.all.map(&:name)

users = [
  {
    email: 'user1@neta.com',
    name: 'user1',
    phone: '1231231000',
    constituency: Constituency.where("parent_id is not null").first,
    religion: religions.sample,
    caste: castes.sample,
    profession: professions.sample,
    education: education_levels.sample,
    pincode: "560001"
  },
  {
    email: 'user2@neta.com',
    name: 'user2',
    phone: '1231231001',
    constituency: Constituency.where("parent_id is not null").first,
    religion: religions.sample,
    caste: castes.sample,
    profession: professions.sample,
    education: education_levels.sample,
    pincode: "560001"
  },
  {
    email: 'user3@neta.com',
    name: 'user3',
    phone: '1231231002',
    constituency: Constituency.where("parent_id is not null").first,
    religion: religions.sample,
    caste: castes.sample,
    profession: professions.sample,
    education: education_levels.sample,
    pincode: "560001"
  },
  {
    email: 'neta1@neta.com',
    name: 'neta1',
    phone: '1231231231',
    constituency: Constituency.where("parent_id is not null").first,
    religion: religions.sample,
    caste: castes.sample,
    profession: professions.sample,
    education: education_levels.sample,
    pincode: "560001",
    income: "Rs 120000",
    assets: "Rs 1200000",
    liabilities: "Rs 200000",
    criminal_cases: "none",
    website: "mpsinha@neta.com",
    twitter: "twitter.com/mpsinha",
    facebook: "facebook.com/mpsinha"
  },
  {
    email: 'neta2@neta.com',
    name: 'neta2',
    phone: '1231231230',
    constituency: Constituency.where("parent_id is not null").first,
    religion: religions.sample,
    caste: castes.sample,
    profession: professions.sample,
    education: education_levels.sample,
    pincode: "560001",
    income: "Rs 220000",
    assets: "Rs 200000",
    liabilities: "Rs 2000000",
    criminal_cases: "1. For attempting to kill Baba Ramdev",
    website: "mpring@neta.com",
    twitter: "twitter.com/mpring",
    facebook: "facebook.com/mpring"
  },
  {
    email: 'neta3@neta.com',
    name: 'neta3',
    phone: '1231231232',
    constituency: Constituency.where("parent_id is not null").first,
    religion: religions.sample,
    caste: castes.sample,
    profession: professions.sample,
    education: education_levels.sample,
    pincode: "560001",
    income: "Rs 100000",
    assets: "Rs 1000000",
    liabilities: "Rs 500000",
    criminal_cases: "1. Murder Case",
    website: "mpdmukh@neta.com",
    twitter: "twitter.com/mpdmukh",
    facebook: "facebook.com/mpdmukh"
  }
]

users.each do |user|
  email = user[:email]
  name = user[:name]
  phone = user[:phone]
  constituency = user[:constituency]
  religion = user[:religion]
  caste = user[:caste]
  profession = user[:profession]
  education = user[:education]
  income = user[:income]
  assets = user[:assets]
  liabilities = user[:liabilities]
  criminal_cases = user[:criminal_cases]
  website = user[:website]
  twitter = user[:twitter]
  facebook = user[:facebook]
  new_user = User.find_or_create_by(email: email, name: name) do |created_user|
    created_user.firebase_user_id = SecureRandom.urlsafe_base64(nil, false)
    created_user.password = "test1234"
    created_user.profile = Profile.new
  end
  new_user.phone_number = phone
  new_user.assembly_constituency = constituency if constituency
  profile = new_user.profile
  profile.religion = Religion.find_by(name: religion)
  profile.caste = Caste.find_by(name: caste)
  profile.profession = Profession.find_by(name: profession)
  profile.education = Education.find_by(name: education)
  profile.contact[:pincode] = user[:pincode]
  profile.financials[:income] = income if income
  profile.financials[:assets] = assets if assets
  profile.financials[:liabilities] = liabilities if liabilities
  profile.civil_record[:criminal_cases] = criminal_cases if criminal_cases
  profile.contact[:email] = email if email
  profile.contact[:website] = website if website
  profile.contact[:twitter] = twitter if twitter
  profile.contact[:facebook] = facebook if facebook
  profile.save!
  new_user.save!
end

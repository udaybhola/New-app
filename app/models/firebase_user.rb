class FirebaseUser < ActiveRecord::Base
  def login(token, uid)
    firebase_infos = firebase_verification(token)

    raise "cant match uid from firebase server for sent jwt token  jwt_token: #{token} and response: #{firebase_infos}" if firebase_infos['users'][0]['localId'] != uid

    self.firebase_response = firebase_infos
    save

    user = User.unscoped.find_by(firebase_user_id: uid)
    
    if !user.nil? && user.archived
      raise "cant login as user is archived"
    end

    phone_number = firebase_infos['users'][0]['phoneNumber']
    if user.nil?
      user = User.new(email: "firebase_#{uid}@neta-firebase.in", password: Devise.friendly_token, firebase_user_id: firebase_infos['users'][0]['localId'])
      
      ## check whether user is candidate
      search_phone_number = phone_number.include?("+91") ? phone_number[3..-1] : phone_number
      candidate = Candidate.find_by(link_phone_number: search_phone_number, should_link_with_phone_number: true)
      if candidate.nil?
        user.profile = Profile.new
      else
        if candidate.logged_in?
          raise "candidate already logged in, can't link again"
        end

        user.profile = candidate.profile
        current_candidature = candidate.current_candidature
        user.constituency = current_candidature.constituency unless current_candidature.nil?
      end
    end

    user.phone_number = phone_number
    client_id = SecureRandom.urlsafe_base64(nil, false)
    token     = SecureRandom.urlsafe_base64(nil, false)
    expiry = (Time.now + DeviseTokenAuth.token_lifespan).to_i

    user.tokens = {}

    user.tokens[client_id] = {
      token: BCrypt::Password.create(token),
      expiry: expiry
    }

    if user.save
      return user, client_id, token, expiry
    else
      raise "cant save user because : #{user.errors.messages}"
    end
  end

  private

  def firebase_verification(token)
    url = "#{ENV['FIREBASE_ACCOUNT_INFO_URL']}#{ENV['FIREBASE_API_KEY']}"
    firebase_verification_call = HTTParty.post(url, headers: { 'Content-Type' => 'application/json' }, body: { 'idToken' => token }.to_json)
    if firebase_verification_call.response.code == "200"
      firebase_infos = firebase_verification_call.parsed_response
      firebase_infos
    else
      raise "user not found in firebase"
    end
  end
end

module ApiResponseModels
  module ProfileBuilder
    def self.included(klass)
      klass.extend ClassMethods
    end

    module ClassMethods
      def construct_info(profile)
        info = CustomOstruct.new
        info.name = profile.name
        info.profile_pic = profile.profile_pic_obj
        info.cover_photo = profile.cover_photo_obj
        info.age = Time.now.year - profile.date_of_birth.year if profile.date_of_birth
        info.gender = profile.gender
        info.religion = profile.religion.name if profile.religion
        info.caste = profile.caste.name if profile.caste
        info.education = profile.education if profile.education
        info.profession = profile.profession.name if profile.profession
        info.qualification = profile.qualification if profile.qualification
        info.dob = profile.date_of_birth.utc if profile.date_of_birth
        if profile.financials
          info.income = profile.financials["income"]
          info.assets = profile.financials["assets"]
          info.liabilities = profile.financials["liabilities"]
        end
        info.criminal_cases = profile.civil_record["criminal_cases"] if profile.civil_record
        info.pincode = profile.contact["pincode"] if profile.contact["pincode"]
        constituency = profile.user.assembly_constituency if profile.user
        info.state = constituency.country_state.name if constituency
        info.constituency = constituency.name if constituency
        info
      end

      def construct_contact_info(profile)
        contact_info = CustomOstruct.new
        unless profile.contact.nil?
          contact_info.phone = profile.contact["phone"]
          contact_info.email = profile.contact["email"]
          contact_info.website = profile.contact["website"]
          contact_info.facebook = profile.contact["facebook"]
          contact_info.twitter = profile.contact["twitter"]
        end
        contact_info
      end

      def calculate_percentage_completeness(info, contact_info)
        name_present = !info.name.blank?
        profile_pic_present = !info.profile_pic.nil?
        cover_photo_present = !info.cover_photo.nil?
        age_present = !info.age.blank?
        gender_present = !info.gender.blank?
        religion_present = !info.religion.blank?
        caste_present = !info.caste.blank?
        education_present = !info.education.blank?
        profession_present = !info.profession.blank?
        facebook_present = !contact_info.facebook.blank?
        twitter_present = !contact_info.twitter.blank?

        100 - (!name_present ? 20 : 0) - (!profile_pic_present ? 20 : 0) - (!age_present ? 10 : 0) - (!cover_photo_present ? 10 : 0) - (!gender_present ? 10 : 0) - (!education_present ? 10 : 0) - (!profession_present ? 5 : 0) - (!religion_present ? 3 : 0) - (!caste_present ? 2 : 0) - (!twitter_present ? 5 : 0) - (!facebook_present ? 5 : 0)
      end
    end
  end
end

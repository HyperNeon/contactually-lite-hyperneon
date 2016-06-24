FactoryGirl.define do
  factory :contact do |f|
    f.first_name { Faker::Name.first_name }
    f.last_name { Faker::Name.last_name }
    f.email_address { Faker::Internet.email }
    # Can't use Faker as it sometimes creates invalid area codes so using the real number 1-800 Contacts :)
    f.phone_number '1 (800) 266-8228'
    f.company_name { Faker::Company.name }
  end
end

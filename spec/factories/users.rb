FactoryGirl.define do
  factory :user do |f|
    f.email { Faker::Internet.email }
    f.password 'password'
    f.password_confirmation 'password'

    # If we want to define a user that already has some contacts loaded
    factory :user_with_contacts do
      transient do
        contacts_count 5
      end

      after(:create) do |user, evaluator|
        create_list(:contact, evaluator.contacts_count, user: user)
      end
    end
  end
end

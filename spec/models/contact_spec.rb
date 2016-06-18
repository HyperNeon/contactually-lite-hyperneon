require 'rails_helper'

RSpec.describe Contact, type: :model do
  let(:user) { create(:user) }

  describe '.new' do
    context 'when user is not defined' do

      it 'is invalid' do
        expect(build(:contact)).not_to be_valid
      end
    end

    context 'when user is defined' do
      subject(:contact_with_user) { build(:contact, user: user) }

      it { is_expected.to be_valid }

      it 'throws an error if trying to persist a duplicate entry' do
        contact_with_user.save
        expect{ create(:contact, contact_with_user.attributes) }.to raise_error(Mongo::Error::OperationFailure)
      end

      context 'format validations' do

        it 'is invalid if email is not formatted properly' do
          contact_with_user.email_address = 'wrong.com'
          expect(contact_with_user).not_to be_valid
        end

        it 'is invalid if phone number is not formatted properly' do
          # an actual fake number from provided data.tsv
          contact_with_user.phone_number = '037.652.8620'
          expect(contact_with_user).not_to be_valid
        end
      end

      context 'presence validations' do
        subject(:blank_contact_with_user) do
          build(:contact, user: user, phone_number: nil, email_address: nil, first_name: nil, last_name: nil,
            company_name: nil)
        end

        context 'when contact is present' do
          before { blank_contact_with_user.phone_number = '1 (800) 266-8228' }

          it { is_expected.not_to be_valid }

          it 'is valid if any name is present' do
            blank_contact_with_user.first_name = Faker::Name.first_name
            expect(blank_contact_with_user).to be_valid
          end
        end

        context 'when any name is present' do
          before { blank_contact_with_user.last_name = Faker::Name.last_name }

          it { is_expected.not_to be_valid }

          it 'is valid if contact_info is present' do
            blank_contact_with_user.email_address = Faker::Internet.email
            expect(blank_contact_with_user).to be_valid
          end
        end
      end
    end
  end
end

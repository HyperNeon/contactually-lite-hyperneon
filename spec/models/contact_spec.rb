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

  describe '.import_contacts' do
    let(:user) { create(:user) }
    context 'good file' do
      let(:test_data) do
        [
          ['First Name', 'Last Name', 'Email Address', 'Phone Number', 'Company Name'],
          ['fName1', 'lName1', 'email1@test.com', '', ''],
          ['fName2', '', '', '1 (800) 266-8228', 'cName1'],
          ['fName3', 'lName3', 'fake.com', '', ''],
          ['', '', '', '037.652.8620', 'cName2']
        ]
      end
      let(:temp_file) { Tempfile.new(['temp','.tsv']) }
      before do
        test_data.each { |row| temp_file.write(row.join("\t") + "\n") }
        temp_file.rewind
      end
      subject(:import_contacts) { Contact.import_contacts(user, temp_file) }
      after { temp_file.unlink }

      it 'creates one new contact per valid row' do
        import_contacts
        expect(user.contacts.count).to eq(2)
      end

      it 'returns a list of invalid rows with error reasons' do
        expected_result = [
          { row: 3, errors: ['Email address must be a valid format'] },
          { row: 4, errors: ['Phone number must be valid'] }
        ]
        expect(import_contacts).to eq(expected_result)
      end

      it 'returns a row error if an exception is raised for a particular row' do
        allow(Contact).to receive(:new).and_raise(StandardError.new('TEST'))
        expected_result = (1..4).map { |row| { row: row, errors: ['An unexpected error has occurred while processing this line'] } }
        expect(import_contacts).to eq(expected_result)
      end
    end

    context 'bad file' do
      it 'raises a ContactImportError if the file can not be read' do
        file_io = double(readlines: StandardError.new('TEST'), path: 'Test.tsv' )
        expect{ Contact.import_contacts(user, file_io) }.to raise_error(Contact::ContactImportError,
          Contact::ContactImportError::FILE_READ_ERROR)
      end

      it 'returns an ContactImportError if an invalid file extension is provided' do
        file_io = double(path: 'Test.csv')
        expect{ Contact.import_contacts(user, file_io) }.to raise_error(Contact::ContactImportError,
          Contact::ContactImportError::INVALID_FILE_TYPE)
      end
    end
  end
end

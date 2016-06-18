require 'rails_helper'

RSpec.describe User, type: :model do

  context 'new user' do
    let(:user) { create(:user) }

    it 'has an empty associated array of contacts' do
      expect(user.contacts).to eq([])
    end
  end

  context 'user_with contacts' do
    let(:user) { create(:user_with_contacts) }

    it 'has a contact list containing only Contact objects' do
      expect(user.contacts.all? { |c| c.is_a? Contact }).to be true
    end

    it 'has a contact list greater than zero' do
      expect(user.contacts.length).to be > 0
    end
  end
end

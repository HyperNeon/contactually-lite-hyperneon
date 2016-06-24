require 'rails_helper'

RSpec.describe 'contacts/index', type: :feature do
  let(:user) { create(:user) }
  let!(:contact1) do
    create(:contact, :first_name => 'First Name', :last_name => 'Last Name', :email_address => 'test@test.com',
      :phone_number => '1 (800) 266-8228', :company_name => 'Company Name', :user => user
    )
  end
  let!(:contact2) do
    create( :contact, :first_name => 'First Name', :last_name => 'Last Name', :email_address => 'test@test.com',
      :phone_number => '1 (800) 266-8228', :company_name => 'Company Name 2', :user => user
    )
  end
  before { sign_in user }

  it 'renders a list of contacts', js: true do
    visit 'contacts/index'
    assert_selector 'tr>td', :text => 'First Name', :count => 2
    assert_selector 'tr>td', :text => 'Last Name', :count => 2
    assert_selector 'tr>td', :text => 'test@test.com', :count => 2
    assert_selector 'tr>td', :text => Phonelib.parse('1 (800) 266-8228').full_international, :count => 2
    assert_selector 'tr>td', :text => /\ACompany Name\z/, :count => 1
    assert_selector 'tr>td', :text => /\ACompany Name 2\z/, :count => 1
  end

  it 'removes a contact when delete is clicked', js: true do
    visit 'contacts/index'
    row_for_delete = "#contact-#{contact1.id}"
    accept_confirm do
      within find(row_for_delete) do
        click_link 'Delete'
      end
    end
    expect(page).not_to have_css(row_for_delete)
  end
end

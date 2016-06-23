require 'rails_helper'

RSpec.describe 'contacts/index', type: :view do
  let(:user) { create(:user) }
  before(:each) do
    sign_in :user, user
    assign(:contacts, [
      Contact.create!(
        :first_name => 'First Name',
        :last_name => 'Last Name',
        :email_address => 'test@test.com',
        :phone_number => '1 (800) 266-8228',
        :company_name => 'Company Name',
        :user => user
      ),
      Contact.create!(
        :first_name => 'First Name',
        :last_name => 'Last Name',
        :email_address => 'test@test.com',
        :phone_number => '1 (800) 266-8228',
        :company_name => 'Company Name 2',
        :user => user
      )
    ])
  end

  it 'renders a list of contacts' do
    render
    assert_select 'tr>td', :text => 'First Name', :count => 2
    assert_select 'tr>td', :text => 'Last Name', :count => 2
    assert_select 'tr>td', :text => 'test@test.com', :count => 2
    assert_select 'tr>td', :text => '1 (800) 266-8228', :count => 2
    assert_select 'tr>td', :text => 'Company Name', :count => 1
    assert_select 'tr>td', :text => 'Company Name 2', :count => 1
  end
end

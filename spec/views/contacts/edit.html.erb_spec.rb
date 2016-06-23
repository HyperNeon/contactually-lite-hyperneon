require 'rails_helper'

RSpec.describe 'contacts/edit', type: :view do
  let(:user) { create(:user) }
  before(:each) do
    sign_in :user, user
    @contact = assign(:contact, Contact.create!(
      :first_name => 'MyString',
      :last_name => 'MyString',
      :email_address => 'test@test.com',
      :phone_number => '1 (800) 266-8228',
      :company_name => 'MyString',
      :user => user
    ))
  end

  it 'renders the edit contact form' do
    render

    assert_select 'form[action=?][method=?]', contact_path(@contact), 'post' do

      assert_select 'input#contact_first_name[name=?]', 'contact[first_name]'

      assert_select 'input#contact_last_name[name=?]', 'contact[last_name]'

      assert_select 'input#contact_email_address[name=?]', 'contact[email_address]'

      assert_select 'input#contact_phone_number[name=?]', 'contact[phone_number]'

      assert_select 'input#contact_company_name[name=?]', 'contact[company_name]'
    end
  end
end

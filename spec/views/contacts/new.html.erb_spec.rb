require 'rails_helper'

RSpec.describe 'contacts/new', type: :view do
  before(:each) do
    assign(:contact, Contact.new(
      :first_name => 'MyString',
      :last_name => 'MyString',
      :email_address => 'MyString',
      :phone_number => 'MyString',
      :company_name => 'MyString'
    ))
  end

  it 'renders new contact form' do
    render

    assert_select 'form[action=?][method=?]', contacts_path, 'post' do

      assert_select 'input#contact_first_name[name=?]', 'contact[first_name]'

      assert_select 'input#contact_last_name[name=?]', 'contact[last_name]'

      assert_select 'input#contact_email_address[name=?]', 'contact[email_address]'

      assert_select 'input#contact_phone_number[name=?]', 'contact[phone_number]'

      assert_select 'input#contact_company_name[name=?]', 'contact[company_name]'
    end
  end
end

require 'rails_helper'

RSpec.describe 'contacts/show', type: :view do
  let(:user) { create(:user) }
  before(:each) do
    sign_in :user, user
    @contact = assign(:contact, Contact.create!(
      :first_name => 'First Name',
      :last_name => 'Last Name',
      :email_address => 'test@test.com',
      :phone_number => '1 (800) 266-8228',
      :company_name => 'Company Name',
      :user => user
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/First Name/)
    expect(rendered).to match(/Last Name/)
    expect(rendered).to match(/test@test.com/)
    expect(rendered).to match(/1 \(800\) 266-8228/)
    expect(rendered).to match(/Company Name/)
  end
end

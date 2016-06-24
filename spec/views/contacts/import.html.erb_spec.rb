RSpec.describe 'contacts/import', type: :view do
  let(:user) { create(:user) }
  before(:each) do
    sign_in :user, user
    assign(:error_message, 'THIS IS A TEST')
  end

  it 'renders error_messages if they exist' do
    render
    expect(rendered).to match(/THIS IS A TEST/)
  end
end
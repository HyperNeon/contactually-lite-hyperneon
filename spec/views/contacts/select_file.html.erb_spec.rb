require 'rails_helper'

RSpec.describe 'contacts/select_file', type: :view do
  let(:user) { create(:user) }
  before { sign_in :user, user }

  it 'renders the select_file form' do
    render

    assert_select 'form[action=?][method=?]', '/contacts/import', 'post' do
      assert_select 'input#import_file[type=?][required=?]', 'file', 'required'
    end
  end
end
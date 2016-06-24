require 'rails_helper'

RSpec.describe ContactsController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # Contact. As you add validations to Contact, be sure to
  # adjust the attributes here as well.
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:contact, user: user) }

  let(:invalid_attributes) { attributes_for(:contact, email_address: 'wrong.com' ) }

  before { sign_in :user, user }

  describe 'GET #index' do
    it 'assigns all contacts as @contacts' do
      contact = Contact.create! valid_attributes
      get :index, {}
      expect(assigns(:contacts)).to eq([contact])
    end
  end

  describe 'GET #show' do
    it 'assigns the requested contact as @contact' do
      contact = Contact.create! valid_attributes
      get :show, {:id => contact.to_param}
      expect(assigns(:contact)).to eq(contact)
    end
  end

  describe 'GET #new' do
    it 'assigns a new contact as @contact' do
      get :new, {}
      expect(assigns(:contact)).to be_a_new(Contact)
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested contact as @contact' do
      contact = Contact.create! valid_attributes
      get :edit, {:id => contact.to_param}
      expect(assigns(:contact)).to eq(contact)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Contact' do
        expect {
          post :create, {:contact => valid_attributes}
        }.to change(Contact, :count).by(1)
      end

      it 'assigns a newly created contact as @contact' do
        post :create, {:contact => valid_attributes}
        expect(assigns(:contact)).to be_a(Contact)
        expect(assigns(:contact)).to be_persisted
      end

      it 'redirects to the created contact' do
        post :create, {:contact => valid_attributes}
        expect(response).to redirect_to(Contact.last)
      end
    end

    context 'with invalid params' do
      it 'assigns a newly created but unsaved contact as @contact' do
        post :create, {:contact => invalid_attributes}
        expect(assigns(:contact)).to be_a_new(Contact)
      end

      it 're-renders the "new" template' do
        post :create, {:contact => invalid_attributes}
        expect(response).to render_template('new')
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) { { first_name: 'Test1' } }

      it 'updates the requested contact' do
        contact = Contact.create! valid_attributes
        put :update, {:id => contact.to_param, :contact => new_attributes}
        contact.reload
        expect(contact.first_name).to eq('Test1')
      end

      it 'assigns the requested contact as @contact' do
        contact = Contact.create! valid_attributes
        put :update, {:id => contact.to_param, :contact => valid_attributes}
        expect(assigns(:contact)).to eq(contact)
      end

      it 'redirects to the contact' do
        contact = Contact.create! valid_attributes
        put :update, {:id => contact.to_param, :contact => valid_attributes}
        expect(response).to redirect_to(contact)
      end
    end

    context 'with invalid params' do
      it 'assigns the contact as @contact' do
        contact = Contact.create! valid_attributes
        put :update, {:id => contact.to_param, :contact => invalid_attributes}
        expect(assigns(:contact)).to eq(contact)
      end

      it 're-renders the "edit" template' do
        contact = Contact.create! valid_attributes
        put :update, {:id => contact.to_param, :contact => invalid_attributes}
        expect(response).to render_template('edit')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested contact' do
      contact = Contact.create! valid_attributes
      expect {
        delete :destroy, {:id => contact.to_param}
      }.to change(Contact, :count).by(-1)
    end

    it 'redirects to the contacts list' do
      contact = Contact.create! valid_attributes
      delete :destroy, {:id => contact.to_param}
      expect(response).to redirect_to(contacts_url)
    end
  end

  describe 'POST #import' do
    context 'with valid file' do
      let(:test_data) do
        [
          ['First Name', 'Last Name', 'Email Address', 'Phone Number', 'Company Name'],
          ['fName1', 'lName1', 'email1@test.com', '', ''],
          ['fName3', 'lName3', 'fake.com', '', ''],
        ]
      end
      let(:temp_file) { Tempfile.new(['temp','.tsv']) }
      let(:uploaded_file) { ActionDispatch::Http::UploadedFile.new(filename: temp_file.path, tempfile: temp_file) }
      before do
        test_data.each { |row| temp_file.write(row.join("\t") + "\n") }
        temp_file.rewind
      end
      subject(:import) { post :import, {:import_file => uploaded_file} }
      after { temp_file.unlink }

      it 'creates a contact for valid rows' do
        expect{import}.to change(Contact, :count).by(1)
      end

      it 'assigns any errors as @error_message' do
        expected_result = "Row 2: Email address must be a valid format VALUES: #{test_data[2].join(', ')}\n"
        import
        expect(assigns(:error_message)).to eq(expected_result)
      end
    end

    context 'with invalid file' do
      let(:temp_file) { Tempfile.new(['wrong','.csv']) }
      let(:uploaded_file) { ActionDispatch::Http::UploadedFile.new(filename: temp_file.path, tempfile: temp_file) }
      subject(:import) { post :import, {:import_file => uploaded_file} }
      after { temp_file.unlink }

      it 'assigns the error as @error_message' do
        expected_result = Contact::ContactImportError::INVALID_FILE_TYPE
        import
        expect(assigns(:error_message)).to eq(expected_result)
      end
    end
  end
end

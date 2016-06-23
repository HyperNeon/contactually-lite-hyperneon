class ContactsController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_contact, only: [:show, :edit, :update, :destroy]

  # GET /contacts
  # GET /contacts.json
  def index
    # Only display contacts for currently signed in user
    @contacts = current_user.contacts
  end

  # GET /contacts/1
  # GET /contacts/1.json
  def show
  end

  # GET /contacts/new
  def new
    @contact = Contact.new
  end

  # GET /contacts/1/edit
  def edit
  end

  # POST /contacts
  # POST /contacts.json
  def create
    @contact = Contact.new(contact_params)
    @contact.user = current_user
    respond_to do |format|
      if @contact.save
        format.html { redirect_to @contact, notice: 'Contact was successfully created.' }
        format.json { render :show, status: :created, location: @contact }
      else
        format.html { render :new }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contacts/1
  # PATCH/PUT /contacts/1.json
  def update
    respond_to do |format|
      if @contact.update(contact_params)
        format.html { redirect_to @contact, notice: 'Contact was successfully updated.' }
        format.json { render :show, status: :ok, location: @contact }
      else
        format.html { render :edit }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contacts/1
  # DELETE /contacts/1.json
  def destroy
    @contact.destroy
    respond_to do |format|
      format.html { redirect_to contacts_url, notice: 'Contact was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # GET /contacts/select_file
  def select_file
    # Don't need anything here right now as we're just routing to the file upload form
  end

  # POST /contacts/import
  # Takes a submitted file and imports it, then catches any errors and passes them to the view
  def import
    # Uploaded file is actually a ActionDispatch::Http::UploadedFile which has limited functionality
    # so extract out the original tempfile for processing without needing to actually persist it
    file_io = params[:import_file].tempfile
    errors = Contact.import_contacts(current_user, file_io)
    if errors.any?
      # Iterate over all the error messages and formate the error_message to be displayed in the view
      @error_message = errors.inject('') do |message, error|
          message + "Row #{error[:row]}: #{error[:errors].join(", ")} VALUES: #{error[:data]}"
      end
    end
  # Catch any unexpected file level errors like invalid file type and pass the message to the view
  rescue Contact::ContactImportError => e
    @error_message = e.message
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contact
      # Ensure users can only access their own contacts
      @contact = Contact.contacts_for(current_user).find(params[:id])
    rescue
      respond_to do |format|
        format.html { redirect_to({action: :index}, alert: 'INVALID CONTACT') }
        format.json { render json: {alert: 'INVALID CONTACT'}, status: :unprocessable_entity }
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def contact_params
      params.require(:contact).permit(:first_name, :last_name, :email_address, :phone_number, :company_name)
    end
end

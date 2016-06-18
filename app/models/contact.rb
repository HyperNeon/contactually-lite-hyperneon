class Contact
  include Mongoid::Document

  # I'd normally set this up to allow a contact to have multiple email addresses or phone numbers
  # but given the scope of the assignment it doesn't seem necessary.
  field :first_name, type: String
  field :last_name, type: String
  field :email_address, type: String
  field :phone_number, type: String
  field :company_name, type: String

  belongs_to :user
  validates :user, presence: true

  validates :email_address, format: { with: /\A[^@\s]+@[-a-z0-9]+\.[a-z]{2,}/i,
    message: 'Email address must be a valid format' , allow_blank: true }

  # Uses the Phonelib gem and Googles libphonenumber to validate phone numbers for things like
  # real country/area/carrier codes, international formatting
  # Setting allow_blank to true so we can store contacts even if the user doesn't have a number
  validates :phone_number, phone: { allow_blank: true }

  # Creating a custom validation method to ensure at least first-, last-, or company name are present
  # and one of either phone_number or email_address
  validate do |contact|
    contact.any_value_present? attributes: [:first_name, :last_name, :company_name]
    contact.any_value_present? attributes: [:phone_number, :email_address]
  end

  def any_value_present?(attributes: [])
    if attributes.all? { |attr| self[attr].blank? }
      errors.add :base, "At least one of #{attributes.join(", ")} must be present"
    end
  end

  # Because I'm not allowing multiple email addresses or phone numbers per contact I am not going to force uniqueness
  # except when all 5 fields are identical to allow a user to have the same contact listed multiple times
  # with differing numbers, emails, or companies. Setting up an index to enforce this at the db layer to prevent
  # race conditions when running on multiple workers
  index( { first_name: 1, last_name: 1, email_address: 1,
    phone_number: 1, company_name: 1, user_id: 1}, { unique: true, name: 'contact_index' })

end

json.array!(@contacts) do |contact|
  json.extract! contact, :id, :first_name, :last_name, :email_address, :phone_number, :company_name
  json.url contact_url(contact, format: :json)
end

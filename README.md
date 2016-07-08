### React - Flux Demo App

A simple app I built to try out React and Flux in a Rails application. It uses React-Rails, Fluxxor for the front end and MongoDB via Mongoid for the backend. 


##### Details

- Built in Ruby on Rails.
- Allows a user to upload a tab-delimited file of contacts via a web form. The
  file will contain the following columns: `first_name`, `last_name`, `email_address`,
  `phone_number`, `company_name`. There's an example file included (data.tsv).
- Parses the given file, normalizes the data, and stores the information in a
  MongoDB database
- Displays the list of contacts and their data.
- Accompanying specs written in Rspec
- Allows deleting specific contacts via Ajax and for the list to be updated via Flux and React.
- Allow the list of contacts to be filtered via React to show:
  - Only contacts with international numbers
  - Only contacts numbers with an extension
  - Only contacts with `.com` email addresses
  - Order the contacts alphabetically by email address
- User management via Devise
- Uses React Bootstrap via rails-assets.org for easy UI flavor


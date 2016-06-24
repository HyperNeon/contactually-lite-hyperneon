class User
  include Mongoid::Document
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  ## Database authenticatable
  field :email,              type: String, default: ""
  field :encrypted_password, type: String, default: ""

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  ## Rememberable
  field :remember_created_at, type: Time

  ## Trackable
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  # Setting up relation of contact model to User. I would have used embed_many instead of has_many since a list
  # of contacts will only ever belong so a single user and we don't want to cross pollinate so there's no need
  # for a separate collection, but mongo has an open bug (https://jira.mongodb.org/browse/SERVER-1068) that prevents
  # unique indices from being enforced within a single document. Uniqueness enforcement at the DB layer is critical
  # to prevent race conditions in a distributed environment so went with a has_many relationship and used the
  # associated foreign key to create the required index
  has_many :contacts

end

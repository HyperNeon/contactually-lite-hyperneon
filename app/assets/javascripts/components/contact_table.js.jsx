// Flux Store and React Component for managing the Contacts Table 

/* Wrapping everything in a global function we call on page load. Could probably
avoid this by having the store load from the backend directly instead of relying on Rails instance variables,
but for now this works*/

window.loadContactsTable = function(contacts) {
    // Setup Flux store for Contacts
    var fluxContactsStore = {};

    // List of constants for available actions
    fluxContactsStore.constants = {
        DELETE_CONTACT: "DELETE_CONTACT"
    };

    fluxContactsStore.store = Fluxxor.createStore({
        initialize: function(options) {
            // We manage the contact list in the store
            this.contacts = options.contacts || [];
            // Contacts can only currently be deleted from the store
            this.bindActions(fluxContactsStore.constants.DELETE_CONTACT, this.onDeleteContact);
        },
        getState: function() {
            // Return the list of contacts in the store
            return {
                contacts: this.contacts,
            };
        },
        onDeleteContact: function(payload) {
            // Remove the contact from the store
            this.contacts = this.contacts.filter(function(contact) {
                return contact._id.$oid != payload.contact._id.$oid
            });
            // Signal to listeners that a change has occurred
            this.emit("change");
        }
    });

    fluxContactsStore.actions = {
        deleteContact: function(contact) {
            // Ping rails contacts json endpoint to delete contact from backend
            $.ajax({
                type: "DELETE",
                url: "/contacts/" + contact._id.$oid + ".json",
                success: function(data) {
                    // If successful, dispatch the delete contact action to the store
                    this.dispatch(fluxContactsStore.constants.DELETE_CONTACT, {
                        contact: contact
                    });
                    // Notify the user the contact was deleted
                    $.notify({
                        message: 'Contact Deleted'
                    },{
                        type: "info"
                    });
                }.bind(this),
                error: function() {
                    // If we receive an error, notify the user and do not update the store
                    $.notify({
                        message: 'Error deleting the contact'
                    },{
                        type: 'danger'
                    });
                }
            });
        }
    };

    // Initialize the Fluxxor store with a list of contacts
    fluxContactsStore.init = function(contacts) {
        var tempStore = {
            ContactsStore: new fluxContactsStore.store({
                contacts: contacts
            })
        };
        fluxContactsStore.flux = new Fluxxor.Flux(tempStore, fluxContactsStore.actions);
    }

    // Enable React-Bootstrap table
    var Table = ReactBootstrap.Table;

    // Define React Components

    var ContactsTable = React.createClass({
        // Watch the ContactsStore and update when a change is emitted
        mixins: [Fluxxor.FluxMixin(React), Fluxxor.StoreWatchMixin("ContactsStore")],
        // Get the list of contacts from the store
        getStateFromFlux: function() {
            var flux = this.getFlux();
            return {
                contacts: flux.store("ContactsStore").getState().contacts
            };
        },
        getInitialState: function() {
            return {
                emailSort: 'UNSORTED'
            };
        },
        handleClick: function(e) {
            // When the email header is clicked, loop through the possible sort styles and update state
            e.preventDefault();
            var current_sort = this.state.emailSort;
            switch(current_sort) {
                case 'UNSORTED':
                    current_sort = 'ASC';
                    break;
                case 'ASC':
                    current_sort = 'DESC';
                    break;
                default:
                    current_sort = 'UNSORTED';
            }

            this.setState({
                emailSort: current_sort
            });
        },
        // Render the Contacts table
        render: function() {
            var props = this.props;
            // Create a contact element for each contact in the store which matches the filters
            var contacts = [];

            // Sort the contact_list according to the current state
            var contact_list = this.state.contacts.slice(0);
            if (this.state.emailSort == 'ASC') {
                contact_list.sort(sortContactsByEmail);
                arrow = "glyphicon glyphicon-circle-arrow-down";
            } else if (this.state.emailSort == 'DESC') {
                contact_list.sort(sortContactsByEmail);
                contact_list.reverse();
                arrow = "glyphicon glyphicon-circle-arrow-up";
            } else {
                arrow = "";
            }

            contact_list.forEach(function (contact) {
                // Only display a row if all active filters are passing
                if (internationalNumberChecker(contact, this.props.internationalNumbersOnly) &&
                    extensionNumberChecker(contact, this.props.extensionNumbersOnly) &&
                    comEmailAddressChecker(contact, this.props.comEmailAddressesOnly))
                {
                    contacts.push( <Contact contact={contact} key={contact._id.$oid} flux={props.flux} /> );
                }
            }.bind(this));
            return (
                // Create a striped Bootstrap table
                <Table striped>
                    <thead>
                    <tr>
                        <th>First name</th>
                        <th>Last name</th>
                        <th><a href="#" onClick={this.handleClick}>Email address<span className={arrow}/></a>
                        </th>
                        <th>Phone number</th>
                        <th>Company name</th>
                        <th colspan="3"></th>
                    </tr>
                    </thead>
                    <tbody>
                        {contacts}
                    </tbody>
                </Table>
            );
        }
    });

    // Returns true if we have an international number of if we're not filtering by internationalNumbersOnly
    function internationalNumberChecker(contact, internationalNumbersOnly) {
        return contact.international_number || !internationalNumbersOnly;
    }

    // Returns true if an extension is in the phonenumber or if we're not filtering by extensionNumbersOnly
    function extensionNumberChecker(contact, extensionNumbersOnly) {
        return contact.phone_number.indexOf('#') > -1 || !extensionNumbersOnly;
    }

    // Returns true if .com is in the email_address or if we're not filtering by extensionNumbersOnly
    function comEmailAddressChecker(contact, comEmailAddressesOnly) {
        return /.com$/.test(contact.email_address) || !comEmailAddressesOnly;
    }

    //This will sort the contact by Email address
    function sortContactsByEmail(a, b){
        var aEmail = a.email_address || '';
        var bEmail = b.email_address || '';
        aEmail = aEmail.toLowerCase();
        bEmail = bEmail.toLowerCase();
        return ((aEmail < bEmail) ? -1 : ((aEmail > bEmail) ? 1 : 0));
    }

    // Add some more bootstrap React components for help with forms
    var FormGroup = ReactBootstrap.FormGroup;
    var ControlLabel = ReactBootstrap.ControlLabel;

    // React component which displays the form for filtering results
    var SearchBar = React.createClass({
        // Pass the current status of the filters back up the chain on user input
        handleChange: function() {
            this.props.onUserInput(
                this.refs.internationalNumbersOnly.checked,
                this.refs.extensionNumbersOnly.checked,
                this.refs.comEmailAddressesOnly.checked
            );
        },
        render: function() {
            return (
                <form>
                    <ControlLabel>Filters</ControlLabel>
                    <FormGroup>
                        <label className='checkbox-inline' >
                            <input type="checkbox" checked={this.props.internationalNumbersOnly} ref="internationalNumbersOnly"
                                      onClick={this.handleChange}/> Only International Numbers
                        </label>
                        <label className='checkbox-inline' >
                        <input  type="checkbox" checked={this.props.extensionNumbersOnly} ref="extensionNumbersOnly"
                                  onChange={this.handleChange}/> Only Numbers With Extensions
                        </label>
                        <label className='checkbox-inline' >
                        <input type="checkbox" checked={this.props.comEmailAddressesOnly} ref="comEmailAddressesOnly"
                                  onChange={this.handleChange}/> Only .com Email Addresses
                        </label>
                    </FormGroup>                          
                </form>
            );
        }
    });

    // Component which manages state of filters for SearchBar and ContactsTable
    var SearchableContactTable = React.createClass({
       // Set the initial state for table filters
        getInitialState: function() {
           return {
               internationalNumbersOnly: false,
               extensionNumbersOnly: false,
               comEmailAddressesOnly: false
           };
       },

       // Update the state variables on user input
       handleUserInput: function(internationalNumbersOnly, extensionNumbersOnly, comEmailAddressesOnly) {
           this.setState({
               internationalNumbersOnly: internationalNumbersOnly,
               extensionNumbersOnly: extensionNumbersOnly,
               comEmailAddressesOnly: comEmailAddressesOnly
           })
       },

       render: function() {
           return (
               <div>
                   <SearchBar
                       internationalNumbersOnly={this.state.internationalNumbersOnly}
                       extensionNumbersOnly={this.state.extensionNumbersOnly}
                       comEmailAddressesOnly={this.state.comEmailAddressesOnly}
                       onUserInput={this.handleUserInput}
                   />
                   <ContactsTable
                       flux={this.props.flux}
                       internationalNumbersOnly={this.state.internationalNumbersOnly}
                       extensionNumbersOnly={this.state.extensionNumbersOnly}
                       comEmailAddressesOnly={this.state.comEmailAddressesOnly}
                   />
               </div>
           )
       }
    });

    // React component which models our individual contacts
    var Contact = React.createClass({
        // Enable this component to submit actions to the ContactStore
        mixins: [Fluxxor.FluxMixin(React)],
        // Render the table row for the contact
        render: function() {
            // Currently only Delete is handled via Ajax, Show and edit will load separate pages
            var id = this.props.contact._id.$oid;
            return (
                <tr id={'contact-'+id}>
                    <td>{this.props.contact.first_name}</td>
                    <td>{this.props.contact.last_name}</td>
                    <td>{this.props.contact.email_address}</td>
                    <td>{this.props.contact.phone_number}</td>
                    <td>{this.props.contact.company_name}</td>
                    <td><a href={'/contacts/'+id}>Show</a></td>
                    <td><a href={'/contacts/'+id+'/edit'}>Edit</a></td>
                    <td><a href="#" onClick={this.handleDelete}>Delete</a></td>
                </tr>
            )
        },
        handleDelete: function(e) {
            // Send the delete action to the ContactStore
            e.preventDefault();
            if (confirm("Delete " + this.props.contact._id.$oid + "?")) {
                this.getFlux().actions.deleteContact(this.props.contact);
            }
        }
    });
    // Initialize the Fluxxor Store
    fluxContactsStore.init(contacts);
    // Update the div with the ContactTable component
    ReactDOM.render(<SearchableContactTable flux={fluxContactsStore.flux}/>,
        document.getElementById('js-contact-table')
    );

}

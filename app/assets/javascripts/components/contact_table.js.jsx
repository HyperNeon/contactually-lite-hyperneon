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
        // Render the Contacts table
        render: function() {
            var props = this.props;
            // Create a contact element for each contact in the store
            var contacts = this.state.contacts.map(function (contact) {
                return <Contact contact={contact} key={contact._id.$oid} flux={props.flux} />
            });
            return (
                // Create a striped Bootstrap table
                <Table striped>
                    <thead>
                    <tr>
                        <th>First name</th>
                        <th>Last name</th>
                        <th>Email address</th>
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
    ReactDOM.render(<ContactsTable flux={fluxContactsStore.flux}/>,
        document.getElementById('js-contact-table')
    );

}

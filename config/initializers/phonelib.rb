# Going to assume all users are in the US for this assignment,
# but we could move this into the model method and set everything based on
# the users locale at the time we start parsing numbers
Phonelib.default_country = "US"
Phonelib.extension_separate_symbols = '#;xX'
Phonelib.extension_separator = '#'
// testClient.q - Client with port, username, password
// Usage: q testClient.q port username password

args:.z.x;

// Debug: show what we received
-1"Arguments received: ";
show args;
-1"Number of arguments: ",string count args;

// Check we have exactly 3 arguments (port username password)
if[3<>count args; 
    -1"ERROR: Must provide exactly 3 arguments";
    -1"Usage: q testClient.q <port> <username> <password>";
    -1"Example: q testClient.q 5001 mo salah";
    -1"Example: q testClient.q 5002 virgil vandijk";
    exit 1;

    ];

// Parse the arguments
clientPort:"I"$args 0;  // First argument is port
username:`$args 1;      // Second argument is username  
password:args 2;        // Third argument is password

// Validate port number
if[clientPort<1000; 
    -1"ERROR: Port must be >= 1000";
    exit 1;
    ];

// Start this client process on the specified port
-1"Starting client process on port: ",string clientPort;
system"p ",string clientPort;

// Client state
.client.handle:0i;
.client.authenticated:0b;
.client.currentUser:username;
.client.port:clientPort;

// Authenticate with the server
.client.authenticate:{[]
    -1"Attempting to authenticate user: ",string .client.currentUser;
    
    .client.handle:@[hopen;`$":localhost:5092:",string[.client.currentUser],":",password;{`failed}];
    
    if[.client.handle~`failed;
        -1"AUTHENTICATION FAILED for user: ",string .client.currentUser;
        exit 1;
        ];
    
    -1"AUTHENTICATION SUCCESSFUL!";
    -1"User: ",string .client.currentUser;
    -1"Client Port: ",string .client.port;
    .client.authenticated:1b;
    
    result:.client.handle"1+1";
    -1"Connection test result: ",string result;
    }

.client.query:{[q]
    if[not .client.authenticated; :`notAuthenticated];
    .client.handle q
    }

.client.disconnect:{[]
    if[.client.authenticated; hclose .client.handle];
    exit 0;
    }

// Auto-authenticate
.client.authenticate[];

-1"=== CLIENT READY ===";

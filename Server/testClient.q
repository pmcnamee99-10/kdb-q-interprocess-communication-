// testClient.q - Test client for authentication
.client.handle:0i

// Test authentication function
.client.testAuth:{[user;password]
    -1"Testing authentication for user: ",string user;
    
    // Try to connect with credentials
    handle:@[hopen;`$":localhost:5092:",string[user],":",password;{`failed}];
    
    if[handle~`failed;
        -1"Authentication FAILED for ",string[user],"/",password;
        :0b
        ];
    
    -1"Authentication SUCCESS for ",string[user],"/",password;
    -1"Handle: ",string handle;
    
    // Test a simple query
    result:handle"2+2";
    -1"Test query result: ",string result;
    
    // Close connection
    hclose handle;
    1b
    }

// Test all users
.client.runTests:{[]
    -1"\n=== Testing Authentication ===";
    
    // Test valid credentials
    .client.testAuth[`harry;"wizard31"];
    .client.testAuth[`hermione;"timeturner19"];
    .client.testAuth[`admin;"admin123"];
    
    // Test invalid credentials
    -1"\n--- Testing Invalid Credentials ---";
    .client.testAuth[`harry;"wrongpassword"];
    .client.testAuth[`invaliduser;"anypassword"];
    
    -1"\n=== Tests Complete ===";
    }

-1"Test client loaded"
-1"Run .client.runTests[] to test authentication"
-1"Or test individual users with .client.testAuth[`username;\"password\"]"
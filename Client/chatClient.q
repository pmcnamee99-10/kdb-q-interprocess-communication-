// chatClient.q 

// server address
.serverAddr: "::5000"

// connection handle (initialized to null)
.clientHandle: 0N

// store current user
.me: `

// override console input to catch all errors (including syntax errors)
.z.pi:{[input]
    result: @[value; input; {[err;cmd] 
        -1 "Error: Check your syntax";
        $[cmd like "*.chat.Join*"; 
            -1 "  Usage: .chat.Join[`user;\"password\"]";
          cmd like "*.chat.SendMsg*";
            -1 "  Usage: .chat.SendMsg[`user;\"message\"]";
          cmd like "*.chat.GetUsers*";
            -1 "  Usage: .chat.GetUsers[]";
          cmd like "*.chat.Leave*";
            -1 "  Usage: .chat.Leave[]";
            -1 "  Check command syntax"
        ];
        `error
        }[;input]];
    
    if[not `error~result; 
        if[not (::)~result; show result]
    ];
    }

// connect to server
.chat.Join:{[user;pwd]
    if[not -11h=type user; 
        -1 "Error: Username must be a symbol (e.g., `mo)";
        -1 "  Usage: .chat.Join[`user;\"password\"]";
        :();
    ];
    
    if[not 10h=type pwd; 
        -1 "Error: Password must be a string (e.g., \"salah\")";
        -1 "  Usage: .chat.Join[`user;\"password\"]";
        :();
    ];
    
    connStr: .serverAddr,":",string[user],":",pwd;
    result: @[hopen; `$connStr; {[err] `error}];
    
    if[`error~result;
        -1 "Invalid credentials - please enter valid username and password";
        :();
    ];
    
    .clientHandle:: result;
    .me:: user;
    -1 "Connected as ",string[user];
    }

// get online users
.chat.GetUsers:{[]
    if[null .clientHandle; 
        -1 "Not connected! Use .chat.Join[`user;\"password\"] first"; 
        :()
    ];
    
    result: @[.clientHandle; "users"; {[err] -1 "Error getting users: ",err; `error}];
    if[`error~result; :()];
    result
    }

// send message
.chat.SendMsg:{[to;msg]
    if[null .clientHandle; 
        -1 "Not connected! Use .chat.Join[`user;\"password\"] first"; 
        :()
    ];
    
    if[not -11h=type to; 
        -1 "Error: Recipient must be a symbol (e.g., `ryan or `all)";
        -1 "  Usage: .chat.SendMsg[`user;\"message\"]";
        :()
    ];
    
    if[not 10h=type msg; 
        -1 "Error: Message must be a string";
        -1 "  Usage: .chat.SendMsg[`user;\"message\"]";
        :()
    ];
    
    result: @[.clientHandle; (`send;to;.me;msg); {[err] -1 "Error sending message: ",err; `error}];
    if[`error~result; :()];
    -1 "Message sent";
    }

// disconnect
.chat.Leave:{[]
    if[null .clientHandle; 
        -1 "Not connected"; 
        :()
    ];
    @[hclose; .clientHandle; {[err] -1 "Error: ",err}];
    .clientHandle:: 0N;
    .me:: `;
    -1 "Disconnected from chat";
    }

-1 "Chat Client loaded";
-1 "";
-1 "Commands:";
-1 "  .chat.Join[`user;\"pwd\"]      - Connect to chat server";
-1 "  .chat.GetUsers[]               - See who's online";
-1 "  .chat.SendMsg[`user;\"msg\"]   - Send message to user";
-1 "  .chat.SendMsg[`all;\"msg\"]    - Send message to everyone";
-1 "  .chat.Leave[]                  - Disconnect from chat";
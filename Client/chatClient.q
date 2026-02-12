// chatClient.q - Minimal Chat Client

// Get user credentials from command line
getUserInfo:{[]
    id:.Q.opt .z.x;
    idName: (id`ipc)[0];
    idPass: (id`ipc)[1];
    (idName;idPass)
    }

userInfo: getUserInfo[]
.me: userInfo[0]
.myPass: userInfo[1]

// Server address
.serverAddr: "::5000"

// Connection handle (initialized to null)
.clientHandle: 0N


// Connect to server
.chat.Join:{[]
    connStr: .serverAddr,":",.me,":",.myPass;
    .clientHandle:: hopen `$connStr;
    -1 "Connected as ",.me;
    }

// Get online users
.chat.GetUsers:{[]
    .clientHandle "users"
    }
//sendmsg

// Send message: .chat.SendMsg[`user;"msg"] or .chat.SendMsg[`all;"msg"]
.chat.SendMsg:{[to;msg]
    sender:`$(.me);
    .clientHandle (`send;to;sender;msg);
    }

// Function to display messages on client side
displayMsg:{[sender;message]
    -1 "[",string[sender],"]: ",message;
    }

// Auto-connect on startup
.chat.Join[]

-1 "Commands:";
-1 "  .chat.GetUsers[]        - See who's online";
-1 "  .chat.Send[\"user\";\"hi\"] - Send private message";

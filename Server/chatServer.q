// chatServer.q - with DEBUG
\l monitoring.q
\p 5000

// Save original .z.po from logging.q
.orig.zpo:.z.po

// override .z.po to notify all users when someone joinskophugiug8oygy8
.z.po:{[hand]
    // call original handler (logging)
    .orig.zpo[hand];
    
    newUser:.z.u;
    -1 "DEBUG: User ",string[newUser]," connected with handle ",string hand;
    
    // get all other connected handles 
    otherHandles: exec handle from openConns where handle<>hand;
    -1 "DEBUG: Other handles to notify: ",-3!otherHandles;
    
    // notify all other users
    if[count otherHandles;
        msg:"User ",string[newUser]," has joined the chat";
        -1 "DEBUG: Sending message: ",msg;
        {[h;m] neg[h]({-1 x};m)}[;msg] each otherHandles;
    ];
    }

// GetUsers: query openConns from logging.q
GetUsers:{[]
    exec distinct user from openConns
    }

// SendMsg
SendMsg:{[to;sender;message]
    handles:$[to=`all;
        exec handle from openConns;
        exec handle from openConns where user=to
    ];
    if[count handles;
        {neg[x]({-1 x};("[",string[y],"]: ",z))}[;sender;message] each handles;
    ];
    `sent
    }

// Override .z.pg to handle chat commands
.z.pg:{[m]
    `queryLog upsert (.z.u; .z.w; .z.h; .z.p; `$(string .z.a); $[10h=type m;m;string m]; 1b);
    if[10h=type m; if[m~"users"; :GetUsers[]]];
    if[0h=type m; 
        if[count m; 
            if[`send~first m; 
                if[4=count m; :SendMsg[m 1;m 2;m 3]]
            ]
        ]
    ];
    value m
    }

-1 "Chat server started on port 5000";
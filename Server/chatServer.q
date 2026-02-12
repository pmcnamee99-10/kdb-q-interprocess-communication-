\l monitoring.q
\p 5000

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
    show handles;
     // Send message to target handles - FIXED: Send display command, not function
    if[count handles;
        {neg[x]({-1 x};("[",string[y],"]: ",z))}[;sender;message] each handles;
    ];
    `sent;
    
    }
 
// Override .z.pg userTo handle chat commands - Fixed parsing
.z.pg:{[m]
    // Handle string commands
    if[10h=type m; if[m~"users"; :GetUsers[]]];
    
    // Handle list commands (send messages)
    if[0h=type m; 
        if[count m; 
            if[`send~first m; 
                if[4=count m; :SendMsg[m 1;m 2;m 3]]
            ]
        ]
    ];
    
    // Default: execute as normal query
    `queryLog upsert (.z.u; .z.w; .z.h; .z.p; `$(string .z.a); $[10h=type m;m;string m]; 1b);
    value m
    }

-1 "Chat server started on port 5000";
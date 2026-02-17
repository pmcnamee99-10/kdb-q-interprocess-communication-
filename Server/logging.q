// logging.q - Fixed version
\l authentication.q

// Defining query log table schema
queryLog:([] user:`$(); handle:`int$(); hostname:`$(); time:`timestamp$(); ip:`$(); query:(); sync:`boolean$())

// Defining access log table schema - states: `Granted, `Denied, `Closed
accessLog:([] user:`$(); handle:`int$(); hostname:`$(); time:`timestamp$(); ip:`$(); state:`$())

// Defining open connections table Schema
openConns:([] user:`$(); handle:`int$(); time:`timestamp$())

// save original .z.pw from authentication.q
.orig.zpw:.z.pw

// wrap .z.pw to log denied connection attempts
.z.pw:{[user;pwd]
    result:.orig.zpw[user;pwd];
    if[not result;
        // Log denied attempt - handle is null since connection wasn't established
        `accessLog upsert (user; 0Ni; `unknown; .z.p; `$(string .z.a); `Denied)
    ];
    result
    }

// Connection opened successfully - log as granted
.z.po:{[hand]
    `openConns upsert (.z.u; hand; .z.p);
    `accessLog upsert (.z.u; hand; .z.h; .z.p; `$(string .z.a); `Granted)
    }

// Synchronous query handler
.z.pg:{[msg]
    `queryLog upsert (.z.u; .z.w; .z.h; .z.p; `$(string .z.a); msg; 1b);
    value msg
    }

// Asynchronous query handler
.z.ps:{[msg]
    `queryLog upsert (.z.u; .z.w; .z.h; .z.p; `$(string .z.a); msg; 0b);
    neg[.z.w] value msg
    }

// Connection closed - log as closed
.z.pc:{[hand]
    delete from `openConns where handle=hand;
    `accessLog upsert (.z.u; hand; .z.h; .z.p; `$(string .z.a); `Closed)
    }

-1"Logging system loaded - authentication preserved"
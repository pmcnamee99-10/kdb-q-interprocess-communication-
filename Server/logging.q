// logging.q - Fixed version
\l authentication.q

// Defining query log table schema
queryLog:([] user:`$(); handle:`int$(); hostname:`$(); time:`timestamp$(); ip:`$(); query:string (); sync:`boolean$())

// Defining access log table schema
accessLog:([] user:`$(); handle:`int$(); hostname:`$(); time:`timestamp$(); ip:`$(); state:`$())

// Defining open connections table Schema
openConns:([] user:`$(); handle:`int$(); time:`timestamp$())

// Message handlers defined below:

.z.po:{[hand]
    `openConns upsert (.z.u; hand; .z.p);   / Adding connection details to relevant table
    `accessLog upsert (.z.u; hand; .z.h; .z.p; `$(string .z.a); `OPEN)   / Adding access details to relevant table
    }

.z.pg:{[msg]
    `queryLog upsert (.z.u; .z.w; .z.h; .z.p; `$(string .z.a); msg; 1b);   / Log the query - removed 'enlist'
    value msg   / Use 'value' instead of 'eval'
    }

.z.ps:{[msg]
    `queryLog upsert (.z.u; .z.w; .z.h; .z.p; `$(string .z.a); msg; 0b);   / Log the query - removed 'enlist'
    neg[.z.w] value msg   / EXECUTE THE ASYNC QUERY
    }

.z.pc:{[hand]
    delete from `openConns where handle=hand;   / Update connections table when connection is closed
    `accessLog upsert (.z.u; hand; .z.h; .z.p; `$(string .z.a); `CLOSED)   / Update access table when connection is dropped 
    }

-1"Logging system loaded - authentication preserved"
// monitor.q - Fixed monitoring
\l logging.q

// Heartbeats table - responseTime is now TIMESPAN
heartbeats:([] hostname:`$(); port:`int$(); pid:`int$(); handle:`int$(); sendTime:`timestamp$(); responseTime:`timespan$())

// track pending heartbeats
//keyed table that tracks heartbeats waiting for responses
//key column is connection handle, using the handle as the key means only 1 heartbeat per connection
//if we send new heartbeat before response it overwrites
//sendTime: the value column ie when we send heartbeat this does the following:
// we send heartbeat at time t1, response time arrives at t2, enables us to calculate response time
//using t2-t1, this table stores t1 until the response arrives
.monitor.pending:([handle:`int$()] sendTime:`timestamp$())

// save original .z.ps from logging.q
// this handle for incoming messages that are async, cant define a new .z.ps as it would
// overite the logging.q .z.ps so would lose original logging
//saving this to a variable means heartbeats can be handled in a new .z.ps and call orig.zps for everything else

.orig.zps:.z.ps

// override .z.ps to capture heartbeat responses
// this is called when an async message arrives
//here m is the message when the client sends a neg[.z.w](`heartbeat;.z.h;system"p";.z.i)
// the server then recieves m = (`heartbeat;`clientHostname;5001i;12345i)
.z.ps:{[m]
    if[(0h=type m) and (4<=count m) and (`heartbeat~m 0);
    // condition checks if this  message is a heartbeat response?
    // Three conditions must all be true (connected with 'and')
     //Condition 1: (0h=type m) type m returns the datatype code of m0h means general list.
    // A heartbeat response is (`heartbeat;hostname;port;pid) which is a general list
    //If someone sends a string or number, this would be false, if all true then it is processed as heartbeat
        pend:.monitor.pending .z.w; //lookup pending hbeat: Get the stored sendTime for this connection
        if[not null pend`sendTime; //null check, only proceed if we have pending heartbeat for client
            `heartbeats insert (m 1;`int$m 2;"i"$m 3;.z.w;pend`sendTime;.z.p - pend`sendTime);
            delete from `.monitor.pending where handle=.z.w; // insert all this into the heartbeat table and 
        ]; //delete handle from table pending as response given
        :(::); //exit func without passing into og handle so .orig.zps doesnt get passed into it
    ];
    .orig.zps m
    }

// Send heartbeats to connected clients, main function called every 30 sec by timer
.monitor.sendHeartbeats:{[]
    if[0=count openConns; :()]; /error handling, if no connections exit, 
    handles:exec distinct handle from openConns; // query handles, get list of all unique conns, these are handles we need to send hbeats to
    if[0=count handles; -1 "No open connections"; :()];
    -1 "Sending heartbeats to ",string[count handles]," handles";
    {[h]
        `.monitor.pending upsert (h;.z.p); //records sending time, upserts handle and current time to table
        neg[h]"neg[.z.w](`heartbeat;.z.h;system\"p\";.z.i)"; // sends async to handle,
    } each handles; //above, neg[.z.w] sends message as a string so client evals, 
    } //each applies this so each handles for the function 

// Timer
.z.ts:{.monitor.sendHeartbeats[]}
system"t 5000"

-1 "Monitor loaded - heartbeats every 30 seconds"
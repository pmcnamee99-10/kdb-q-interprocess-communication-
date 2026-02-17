// authentication.q 
// initialize users on boot
//usernames as symbols for more efficient lookup
//passwords as strings to hold .Q.sha1 hash text
.perm.users:([username: `$()] password:())

// add user function
//usr and pwd parametr names, will get mapped to table due to position
.perm.addUser:{[usr;pwd] `.perm.users upsert (usr;.Q.sha1 pwd)}

// remove user function  
.perm.removeUser:{[usr] delete from `.perm.users where username = usr}

// set up authentication callback with .Q.sha1 for encryption
.z.pw:{[usr;pwd] $[(.Q.sha1 pwd)~.perm.users[usr][`password];1b;0b]}

// users
.perm.addUser[`mo;"salah"]
.perm.addUser[`virgil;"vandijk"] 
.perm.addUser[`alisson;"becker"]
.perm.addUser[`ryan;"gravenberch"]

// Display users for testing
-1"Users created:";
show .perm.users

// Start server on port 5092
system"p 5092"
-1"Authentication server started on port 5092"
-1"Test users: mo salah, alisson becker, virgil van dijk, ryan gravenberch"
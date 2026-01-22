// authentication.q - Authentication Server
// Initialize user table
.perm.users:([username: `$()] password:())

// Add user function
.perm.addUser:{[usr;pwd] `.perm.users upsert (usr;pwd)}

// Remove user function  
.perm.removeUser:{[usr] delete from `.perm.users where username = usr}

// Set up authentication callback
.z.pw:{[usr;pwd] pwd~.perm.users[usr][`password]}

// Add some test users
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
# kdb-q-interprocess-communication-
Basic IPC project

Instructions

1. Open 4 Ubuntu terminals ( or however many you want to use, one two three... will work for any numnber as long as the users are added)

2. cd into the Server directory on the first one then cd into client on the other 3

3. On the server directory type into the cli : q chatServer.q This will start the server.

4. If you want to add users use the .perm.AddUser[] function within the server cli, there are some default users loaded in stored in memory that you can see in the authentication script

5. In one of the  other terminals call q clientChat.q, then if you wish to log in , use the functions defined in the instructions along with the correct syntax to log in. Other message functions instructions are listed upon boot that can be used 

6. logging and monitoring can be accessed from the server by calling the tables ie queryLog, heartbeats etc.

# Start a session and be guided to setup a user and select a default desktop environment
vncserver

# Start a session with the mate desktop environment
vncserver -select-de mate

# Add a new user with read/write permissions
vncpasswd -u my_username -w -r

# Tail the logs
tail -f ~/.vnc/*.log

# Get a list of current sessions with display IDs
vncserver -list

# Kill the VNC session with display ID :2
vncserver -kill :2


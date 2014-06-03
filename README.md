# Collaborate

Collaborate is a collaboration web application intended for online communities, with integrated blogs, courses, discussion forums, events,
file sharing, and wiki features.

## Directory Structure
- / - Node.js code
- /client - client-side code that runs in the web browser
- /storage - where the data is stored

## Requirements
You need Node.js installed, and install the following dependencies via npm:
- express
- socket.io
- bcrypt-nodejs
- nodemailer
- mysql

The following client side Javascript libraries come with the code:
- jQuery
- jQuery.cookies
- jqWidgets
- TinyMCE
- jQuery hashchange

Collaborate uses MariaDB as the database backend, although MySQL should also work. If you wish to port it to another database,
you'll need to edit Database.js and port mariadb.sql.

## Running
- Set up the database by running mariadb.sql on a MariaDB or MySQL database server.
- Modify the connection settings in Database.js to connect to your database.
- Create a default user by calling the procedure create_user on the database.
- Make sure you have Node.js and dependencies installed and call "node app.js".

## Current features
- Registration and optional e-mail verification for users.

## Planned features
- Blogs
- Courses (divided into classes)
- Discussion forums
- File sharing
- Events (view upcoming calendar and nearby events)
- Wiki
- Private messages
- Real-time chat showing online users


## There's no point trying it out because there's nothing to see yet. Stay tuned!
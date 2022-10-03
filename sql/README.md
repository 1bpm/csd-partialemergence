# Database dump
partialemergence.sql contains an excerpt of the SONICS database system to be used with Partial Emergence. 
The script should be executed on a PostgreSQL server with the version 13.1 or above and will create a database named *partialemergence*, a user with the same name, and relevant objects within the database which are used by SONICS UDOs.

The executing user must have CREATE DATABASE and CREATE USER permissions among others, so it is best to run as an admin user or even the postgres user.

The password for *partialemergence* is hardcoded in the sql script and matches the password specified in sonics/__config__.udo. These should be altered accordingly if required.

If the database is to be run on the same host as Csound runs, then no alterations are required to __config__.udo ; otherwise PGDB_HOST should be changed or the relevant macro passed at invocation. 

The PostgreSQL instance's pg_hba.conf may also need altering in order to allow relevant host based access to the database.
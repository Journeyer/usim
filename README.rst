
.. image:: screen.png
   :scale: 50 %
   :alt: screen capture

News
====

- Both the pure orbit page and lua programming approach implemented     2015.5.5

About
=====
This is just a personnal study of orbit

Testing environment
-------------------

- Ubuntu 12.04

Prerequisite
------------

- server side
::

 sudo apt-get install lua5.1
 sudo apt-get install luarocks
 sudo apt-get install sqlite3 libsqlite3-0 libsqlite3-dev
 (sudo updatedb)
 (sudo locate sqlite3.h)
 (/usr/include/sqlite3.h)
 sudo luarocks install luasql-sqlite3
 git clone https://github.com/keplerproject/orbit
 cd orbit
 ./configure lua
 sudo make install


Minor install trouble shooting needed.

- client side
::

 chrome, IE or what ever browser you prefer


References
==========

This project has been started from the example of Orbit, 'todo' :
https://github.com/keplerproject/orbit/tree/master/samples/todo


Journeyer J. Joh


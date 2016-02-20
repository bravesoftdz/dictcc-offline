# dictcc-offline
FPC/Lazarus App for DICTCCs SQLite DB
needs libsqlite3.so on linux or sqlite3.dll
on ubuntu: sudo apt-get install libsqlite3-dev

# Usage
place the db in the same folder like the executable and start the programm.
Use the field in the upper left corner to search. Double click on a suggestion to search.
Double click on a search result to copy is to clipboard.
CTRL + e for english search. CTRL + d for german search.
ESC to minimize.

# How to get the DB
This programm uses the SQLite DB from the dict.cc Android App.

The simplest way to get this DB, is to download the app, then download the dictionary in the app. The DB will be downloaded to the cc.dict.dictcc folder on your phone. Only copy the file to the same folder, where the programm is located and rename the DB to "dict.db".
Then run the programm to convert the DB.

Currently only the german-english DB is supported and testet.

There is also a way to diretly download the db, but this could be not allowed by dict.cc

# schrisch
Schrank+Tisch = schrisch... 
rack in german Schrank + table in german Tisch => racktables

This project will try to build a substitution for racktables http://racktables.org/.

I will not have a shared centralized server, instead it will use a git archiv for the included
data. The data is in yaml to allow easy merges. And we will use http://eclipse.org/rap/ to
build the frontend with a local running server as the concept of https://c9.io/.

We will render the data to a 3d svg canvas.

the schrisch team

for the racktables2schrick.rb script you need a 
config.yaml in the same directory

that should look like:

api:
  url: http://racktables/api/url

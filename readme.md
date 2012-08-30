Proof-of-concept demo app using edmodo's api

Login to http://concordconsortium.edmodo.com/ as a teacher to create a group and install the app for that group. (The school code will be sent in a separate email.) 

Login to http://concordconsortium.edmodo.com/ as Concord Consortium to change the app's metadata or create new apps. (The credentials will be sent in a separate email.)

The app itself is a simple Sinatra app in the file web.rb with templates in `/views` and static resources in `/public`.

It is currently deployed to Heroku at http://ccedmodo.herokuapp.com/

npaessel@concord.org, sbannasch@concord.org, and aunger@concord.org have been added as collaborators on Heroku.

To gain access to the Heroku version, create an account and/or login to Heroku, follow the quickstart guide https://devcenter.heroku.com/articles/quickstart , and clone the repository and add a 'heroku' remote.

    git clone git@github.com:concord-consortium/ccedmodo.git
    git remote add heroku git@heroku.com:ccedmodo.git

API information lives at http://concordconsortium.edmodobox.com/developer/api and http://concordconsortium.edmodobox.com/developer/sandbox
To access these links, you need to be logged in as Concord Consortium, not a teacher!

Further information is at  http://developers.edmodo.com/guide/

To deploy a new version to Heroku,

    git push # push to Github first to make sure you have the latest!
    git push heroku master # to actually deploy
 
Also see the Heroku collaborator guide, https://devcenter.heroku.com/articles/sharing

Richard Klancer <rklancer@concord.org>

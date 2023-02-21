authentication and authorization

user logs in (username and password)
response is either OK (with redirect url to bitbucket to authorize request) or not OK
If ok, redirect to bitbucket for authorization with state, client id, scope parameters
user accepts or denies
user accepts bitbucket authorization
user gets redirected to app (dbs live page) with code as query param
server will exchange the code with bitbucket access token
server will use access token to git remote the repo in the file server


OR 

connect you account link in file explorer.


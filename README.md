# VMWare_API
Repo with all API scripts related to VMWare


#Bearer token#
First off, you need to get the bearer token. For that I used postman with these parameters.

###Request Type### : POST

###Headers### :

Key = Content-Type / Value = application/json

###Body### :

{
"username": "YourUsername@mydomain",
"password": "YourPassword",
"tenant": "mytenant"
}

Result will give you a 200 response. Simply copy the ID and replace it on the script on $token. Take care to leave "bearer " before !

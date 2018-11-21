# Chiamate non autenticate

Version is the typical call that won't require authentication, thus calling it directly

https://www.taris.it/development/hiworkflows/api/v1/info/version

which returns something like (JSON):
```json
{
  "version": "1.0"
}
```

# Chiamate autenticate con username e password:

To get the token back, you must provide auth credentials, in HTTP_BASIC form,
```
https://www.taris.it/development/hiworkflows/api/v1/info/token
```
Supposing admin:1234 as username:password, here is the sample of headers sent in which YWRtaW46MTIzNA== is the base64 encoding of admin:1234 :
```
Accept: application/json
Content-Type: application/json
Authorization: Basic YWRtaW46MTIzNA==
Accept-Language: it-it
Accept-Encoding: gzip, deflate
```
it returns the AUTH_TOKEN, email and id of the user which performed the authentication:
```json
{
  "token": "VNCg+DCLyzFF3dWW6kdJXTP5c9CGvq1zVK+Pb4lc//9lvqP2sXNHAjg9L4SJK5M98tzZNuw7kV4VqbPMYk57UA==",
  "email": "admin@example.com",
  "roles": [
    ""
  ],
  "admin": true,
  "third_party": false,
  "id": 3
}
```
In case you won't provide right credentials, this is the error you'll recieve:
```json
{
  "error": "bad credentials"
}
```
# Chiamate autenticate con token

Whe you get the token, you could use it to make a search:
```
https://www.taris.it/development/hiworkflows/api/v1/bundles?q[code_eq]=provasv
```
With headers (must be sure to send the Accept, Content-Type and Authorization ones):
```
Accept: application/json
Content-Type: application/json
Authorization: Token token="VNCg+DCLyzFF3dWW6kdJXTP5c9CGvq1zVK+Pb4lc//9lvqP2sXNHAjg9L4SJK5M98tzZNuw7kV4VqbPMYk57UA==", email="admin@example.com"
Accept-Language: it-it
Accept-Encoding: gzip, deflate
```
Which will return an array of bundles which have provasv as code.
```
http://localhost:3000/api/v1/items?pages_info=1&page=1&per=3

{
  "count": 481,
  "current_page_count": 3,
  "next_page": 2,
  "prev_page": null,
  "is_first_page": true,
  "is_last_page": false,
  "is_out_of_range": false,
  "pages_count": 161,
  "current_page_number": 1
}

http://localhost:3000/api/v1/items?count=1

{
  "count": 481
}
```

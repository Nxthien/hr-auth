# Rails Integration with [OmniAuth HrSystem](http://github.com/dieunb/omniauth-hrsystem)

# Only Mobile Auth Via Email / Password

(*) Auth via email, password
POST http://auth.framgia.vn/auth/hr_system/access_token
Params
email - required
password - required
client_id - required
client_secret - required
grant_type (password) - required

example:
curl --data "email=nguyen.binh.dieu@framgia.com&password=12345678&client_id=c550483e49706ba821bccc6bac3f3b1e&client_secret=3b438b7cd973829cfa5233396968267c6c7aef298374561e6d4b4dc26c510b5c&grant_type=password" http://auth.framgia.vn/auth/hr_system/access_token

(*) Auth refresh_token
POST http://auth.framgia.vn/auth/hr_system/access_token
Params
client_id - required
client_secret - required
grant_type (refresh_token) - required

example:
curl --data "client_id=c550483e49706ba821bccc6bac3f3b1e&client_secret=3b438b7cd973829cfa5233396968267c6c7aef298374561e6d4b4dc26c510b5c&grant_type=refresh_token&refresh_token=e440a1239eb5082b8ee84ed23ae1508f" http://auth.framgia.vn/auth/hr_system/access_token

(*) Auth get user info
GET http://auth.framgia.vn/me
Params
access_token - required
example:
curl http://auth.framgia.vn/me?access_token=44bf223d6e47c5c33f8fe99e6ba004a6

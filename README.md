# OtterStore

Otterstore is an app store web app project that focuses on building apps into microservices with Docker.

![Diagram](https://cdn.discordapp.com/attachments/1089997379815604345/1098058546278572113/image.png)

## Installation

Clone the repo

Start All the containers scaled:

```bash
docker-compose up --scale checkout-api=3 --scale store-api=3 -d
```

## Usage

Once everything is running you can access the app at [localhost](http://localhost/)

If you try to check out make sure to use a valid card number that passes Luhn's algorithm

Dummy Card #: **4417-1234-5678-9113**

expirations should be formatted like the following "03/2025"

![Home Light](https://media.discordapp.net/attachments/1089997379815604345/1091128609923674152/image.png?width=2592&height=996)
![Home Dark](https://media.discordapp.net/attachments/1089997379815604345/1091128874747826236/image.png?width=2592&height=1238)
![Cart Dark](https://media.discordapp.net/attachments/1089997379815604345/1091149352111722567/image.png?width=1920&height=180)

![Checkout](https://cdn.discordapp.com/attachments/1089997379815604345/1091129034341105824/image.png)
![Checkout Sucess](https://media.discordapp.net/attachments/1089997379815604345/1091130083336523906/image.png?width=2592&height=876)


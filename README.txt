# OtterStore

Otterstore is an app store web app project that focuses on building apps into microservices with Docker.

## Installation

Make sure you have python installed and have the pymongo package installed
```bash
pip install pymongo
```

Clone the repo

Start All the containers:

```bash
docker-compose up -d
```

Once all containers are running in Docker, run the sampledata.py file to add sample apps to Otterstore.

```bash
python sampledata.py
```

## Usage

Once the App is running you can access it at [localhost](http://localhost/)

If you try to check out make sure to use a valid card number that passes Luhn's algorithm

Dummy Card #: **4417-1234-5678-9113**

expirations should be formatted like the following "03/2025"
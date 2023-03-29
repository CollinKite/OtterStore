from flask import Flask, request, jsonify
from flask_cors import CORS
from bson import json_util
import pymongo
import json

#SET DB URL HERE
DB_URL = "mongo"

#Setup Flask
app = Flask(__name__)
CORS(app)

#Setup MongoDB
try:
    client = pymongo.MongoClient("mongodb://root:example@"+ DB_URL +":27017/")
    db = client["OtterStore"]
except:
    print("Error connecting to MongoDB")
    exit(1)


@app.route('/apps', methods=['GET'])
def get_apps():
    # Get all JSON objects from the Apps collection
    apps = db["Apps"].find()
    # Convert the JSON objects to a list
    apps = list(apps)
    # Convert ObjectId to string
    for app in apps:
        app["_id"] = str(app["_id"])
    # Return the list of apps
    return json.dumps(apps, default=json_util.default), 200


@app.route('/apps', methods=['POST'])
def add_app():
    #Get the imageURL, Title, Description, and Price
    imageURL = request.json['imageURL']
    title = request.json['title']
    description = request.json['description']
    price = request.json['price']

    #make sure the app doesn't already exist
    if db["Apps"].find_one({"title": title}) is not None:
        return jsonify({"Message": "App already exists"}), 400

    #Insert the app into the database
    db["Apps"].insert_one({
        "imageURL": imageURL,
        "title": title,
        "description": description,
        "price": price
    })
    return jsonify({"Message": "App Added"}), 200

@app.route('/apps/<title>', methods=['DELETE'])
def delete_app(title):
    #Find the app by ID and delete it or if the app doesn't exist return an error
    if db["Apps"].find_one({"title": title}) is None:
        return jsonify({"Message": "App not found"}), 404
    else:
        #find app by id and delete it
        db["Apps"].delete_one({"title": title})
        return jsonify({"Message": "App Deleted"}), 200
    
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)
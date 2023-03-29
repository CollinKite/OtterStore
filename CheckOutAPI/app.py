from flask import Flask, request, jsonify
from flask_cors import CORS
from bson import json_util
from bson.objectid import ObjectId
from datetime import datetime
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

def verify_card(card_number, expiration, cvv):
    # Remove spaces and dashes from the card number
    card_number = card_number.replace(" ", "").replace("-", "")

    # Check if the card number is valid using Luhn's algorithm
    checksum = 0
    digits = list(map(int, card_number))
    digits.reverse()

    for i in range(len(digits)):
        if i % 2 == 0:
            checksum += digits[i]
        else:
            double = digits[i] * 2
            if double > 9:
                double -= 9
            checksum += double

    if checksum % 10 != 0:
        return False

    # Check if the expiration date is valid (e.g. "04/23")
    try:
        month, year = expiration.split("/")
        month = int(month)
        year = int(year)
        #get the current year and month
        current_year = datetime.now().year
        current_month = datetime.now().month
        
        #check if the expiration date is in the future
        if year < current_year or (year == current_year and month < current_month):
            return False
    except:
        return False

    # Check if the CVV is valid (e.g. "123")
    if not (len(cvv) == 3):
        return False
    else:
        return True

@app.route('/order', methods=['POST'])
def add_order():
    #Get the email, app id, card number, expiration, and cvv from the request
    email = request.json['email']
    app_id = request.json['app_id']
    card_number = request.json['card_number']
    expiration = request.json['expiration']
    cvv = request.json['cvv']

    #Check if the card is valid
    if not verify_card(card_number, expiration, cvv):
        return jsonify({"Message": "Invalid Card"}), 400

    #Check if app exists by its object id
    objInstance = ObjectId(app_id)
    if db["Apps"].find_one({"_id": objInstance}) is None:
        return jsonify({"Message": "No valid app with this id"}), 404
    
    #Check if the user has already ordered the app
    if db["Orders"].find_one({"email": email, "app_id": app_id}) is not None:
        return jsonify({"Message": "Order already exists"}), 400

    # Add the order to the database
    db["Orders"].insert_one({
       "email": email,
      "app_id": app_id
    }) 
    return jsonify({"Message": "Order Added"}), 200

@app.route('/orders', methods=['DELETE'])
def delete_app():
    #Get Email From Request
    email = request.json['email']
    #Check if any orders with the email exists
    if db["Apps"].find_one({"email": email}) is None:
        return jsonify({"Message": "No valid orders with this email"}), 404
    
    #Delete all orders with the email
    db["Orders"].delete_many({"email": email})
    return jsonify({"Message": "Orders Deleted"}), 200

@app.route('/orders', methods=['GET'])
def get_orders():
    #Get all orders with the email
    orders = list(db["Orders"].find())

    for order in orders:
        order["_id"] = str(order["_id"])

    return json.dumps(orders, default=json_util.default), 200



if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5002)
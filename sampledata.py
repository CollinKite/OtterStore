import pymongo

#SET DB URL HERE
DB_URL = "localhost"

#connect to MongoDB
client = pymongo.MongoClient("mongodb://root:example@"+ DB_URL +":27017/")

#connect to sample database
db = client.OtterStore

#connect to Apps Collection
apps = db.Apps

json_data = [
    {
        "imageURL":"https://deadline.com/wp-content/uploads/2022/08/Netflix_Symbol_logo.jpg?w=1024",
        "title":"Netflix",
        "description":"A Movie Streaming App",
        "price":"0.00"
    },
    {
        "imageURL":"https://assets.materialup.com/uploads/a6c2a3e2-ec04-4aa0-9a8d-ee3ece0cf123/preview.jpg",
        "title": "Procreate Pocket",
        "description": "A Powerful Sketching, Painting, and Illustration App",
        "price": "4.99"
    },
    {
        "imageURL":"https://e7.pngegg.com/pngimages/976/598/png-clipart-facetune-android-mobile-phones-android-blue-photography.png",
        "title": "Facetune",
        "description": "A Photo Editing App for Enhancing and Retouching Selfies",
        "price": "3.99"
    },
    {
        "imageURL":"https://darksky.net/dev/img/logo.png",
        "title": "Dark Sky Weather",
        "description": "A Hyperlocal Weather Forecasting and Alert App",
        "price": "3.99"
    },
    {
        "imageURL":"https://i.pinimg.com/originals/1b/1b/da/1b1bdab10e8672ebb68bf64fbef67b81.png",
        "title": "Headspace",
        "description": "A Guided Meditation and Mindfulness App",
        "price": "12.99/month"
    },
    {
        "imageURL":"https://play-lh.googleusercontent.com/gxylrEt14mAOWhHLJbuHg7lIa3h8t5tLbXcCZL_ox437C4UVO7Euk9rj6fjGLUdnTWw=w240-h480-rw",
        "title": "Alto's Adventure",
        "description": "An Endless Snowboarding Adventure Game",
        "price": "4.99"
    },
    {
        "imageURL":"https://www.forestapp.cc/img/icon.png",
        "title": "Forest",
        "description": "A Productivity App that Encourages Focus by Growing Virtual Trees",
        "price": "1.99"
    },
    {
        "imageURL":"https://assets.materialup.com/uploads/c623f426-b2b1-4426-838c-9c89abccbff8/preview.jpg",
        "title": "TouchRetouch",
        "description": "A Photo Editing App for Removing Unwanted Objects and Blemishes",
        "price": "1.99"
    },
    {
        "imageURL":"https://images.rawpixel.com/image_png_800/czNmcy1wcml2YXRlL3Jhd3BpeGVsX2ltYWdlcy93ZWJzaXRlX2NvbnRlbnQvdjk4Mi1kNS0wOC5wbmc.png?s=zjc--Zf0JsarEStBEzBKjop4SQmThizDgE6EoM2umxw",
        "title": "TikTok",
        "description": "A Short-form Video Sharing App",
        "price": "0.00"
    },
    {
        "imageURL":"https://cdn-icons-png.flaticon.com/512/174/174855.png",
        "title": "Instagram",
        "description": "A Photo and Video Sharing Social Network",
        "price": "0.00"
    }
]

#insert data into Apps Collection
apps.insert_many(json_data)
print("Data Inserted")


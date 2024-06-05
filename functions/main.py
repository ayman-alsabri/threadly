# Welcome to Cloud Functions for Firebase for Python!
# To get started, simply uncomment the below code or create your own.
# Deploy with `firebase deploy`

import token
from firebase_functions import https_fn,options
from firebase_admin import initialize_app , firestore , messaging

initialize_app()
 
options.set_global_options(max_instances=10)


@https_fn.on_call()
def sendAddWorkRequest(request: https_fn.CallableRequest) -> https_fn.Response:
    data = request.data
    message = messaging.Message(
        token=data['token'],
        data=data['data'],
        android=messaging.AndroidConfig(priority='high'),
        # snotification=messaging.Notification(title="تم اضافة عمل جديد بواسطة "+data['workerName'],
        # body=data['messageBody'],
        # )
    )
    try:
        messaging.send(message)
    except:
        message2 = messaging.Message(
        token=data['myToken'],
        data={'id':data['id']},
        android=messaging.AndroidConfig(priority='high'),
        )
        messaging.send(message2)




@https_fn.on_call()
def responsForPaidAll(req: https_fn.Request) -> https_fn.Response:
# data has 

# ok? 
# shopId
# workerId
# id
# date
# amount
# token
# message
# messageBody
    


    data = req.data
    if(data['ok']):
     db = firestore.client()
     db.collection("users/"+data["shopId"]+"/workers/"+ data["workerId"] +"/paidAll").document(data["date"]).create({
         'amount': int(data["amountSpent"]),
         'id': int( data['id']),
     })

    message = messaging.Message(
        token=data['token'],
        android=messaging.AndroidConfig(priority='high',),
        data=data['data'],
        # notification=messaging.Notification(title=data['message'],  body=data['messageBody'],                                
        # 
    )
    try:
        messaging.send(message)
    except Exception as error:
       print(error)

@https_fn.on_call()
def notifyManager(req: https_fn.Request) -> https_fn.Response:
    data = req.data
    message = messaging.Message(
        token=data['token'],
        android=messaging.AndroidConfig(priority='high',),
        data=data['data'],
    )
    try:
        messaging.send(message)
    except Exception as error:
       print(error)
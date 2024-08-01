import argparse
import firebase_admin
from firebase_admin import credentials, firestore
from huggingface_hub import InferenceClient
import cv2
from PIL import Image
import numpy as np
from transformers import pipeline
from io import BytesIO
import requests
import time

import gspread
from google.oauth2.service_account import Credentials

# Set up the Google Sheets API client
scopes = ["https://www.googleapis.com/auth/spreadsheets"]
creds = Credentials.from_service_account_file("/kaggle/input/credentials-api/credentials.json", scopes=scopes)
client = gspread.authorize(creds)

sheet_id = "1PMHGHpgZhec6-Q39N0JKVl3kyDSk_LFucsD2KIdIzX8"
workbook = client.open_by_key(sheet_id)
sheet = workbook.sheet1
cred = credentials.Certificate('/kaggle/input/api-firebase/farm-expert-a0c36-firebase-adminsdk-w8w51-62e410945f.json')
firebase_admin.initialize_app(cred)

class Model:
    def __init__(self):
        # Initialize Firebase
        self.db = firestore.client()
        self.db_ref = self.db.collection('user_data')
        self.pipe = pipeline("image-classification", 
                             model="linkanjarad/mobilenet_v2_1.0_224-plant-disease-identification")


        self.client = InferenceClient(
            "meta-llama/Meta-Llama-3-8B-Instruct",
            token="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",
        )

    def get_prediction(self,image):
#         print(self.pipe(image))
         return self.pipe(image)[0]['label']

    def get_advice_of_predicted_label(self,label):

        user_messages = [{'role':'system','content':"You are a helpful farm Expert and reply in short"},{'role':'user','content':f"Wrtie down some steps/points to deal with {label}"}]

        message = self.client.chat_completion(
                    messages=user_messages,
                    temperature=0.9,
                    max_tokens=6000,
                    stream=False,
                )
        
        reply = message.choices[0].message.content
        return reply
    

    def chat_completion(self,user_messages):
        message = self.client.chat_completion(
                messages=user_messages,
                temperature=0.9,
                max_tokens=6000,
                stream=False,
            )
        reply = message.choices[0].message.content
        return reply
    
    def handle_image(self,user_id):
        db_ref = self.db_ref.document(user_id).collection('images')
        print([doc.id for doc in db_ref.stream()])
        doc_ids = [doc.id for doc in db_ref.order_by('createdAt', direction=firestore.Query.DESCENDING).stream()][0]
        image_url = db_ref.document(doc_ids).get().to_dict()["imageUrl"]
#         try:
#             # Fetch the image
#             response = requests.get(image_url)
#             response.raise_for_status()  # Check for request errors
#         except Exception as e:
#             print(e)

#         image = Image.open(BytesIO(response.content))
#         image = np.array(image)
        label = self.get_prediction(image_url)
        print(label)
        self.db_ref.document(doc_ids).update({'label': label})
        self.db_ref.document(doc_ids).update({'advice': self.get_advice_of_predicted_label(label)})

    def handle_chat(self,user_id):
        db_ref = self.db_ref.document(user_id).collection('chat')
        print(db_ref)
        doc_ids = [doc.id for doc in db_ref.order_by('createdAt', direction=firestore.Query.DESCENDING).stream()]

        user_messages=[{"role": "system", "content": "You are a helpful farm expert and give replies in short."}]

        for chat_id in doc_ids[0:max(6,len(doc_ids))][::-1]:
            chat = db_ref.document(chat_id)
            user_messages.append({"role": "user", "content": chat.get().to_dict()["message"]})

        reply = self.chat_completion(user_messages)
        print(doc_ids)
        self.db_ref.document(doc_ids[0]).update({'reply': reply})

    
def main(model, user_id, content_type):
    if content_type == 'image':
        model.handle_image(user_id)
    elif content_type == 'chat':
        model.handle_chat(user_id)

model = Model()

# Get the values of the first row
while True:
    values_list = sheet.row_values(1)
    if values_list != []:
        user_id = values_list[0]
        content_type = values_list[1]

        main(model, user_id, content_type)

        sheet.delete_rows(1)
    time.sleep(1)
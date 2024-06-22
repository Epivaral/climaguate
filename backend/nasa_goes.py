import logging
import azure.functions as func

import requests
import pyodbc
from azure.identity import DefaultAzureCredential
from azure.storage.blob import BlobServiceClient
import datetime

app = func.FunctionApp()

@app.schedule(schedule="0 0 * * * *", arg_name="nasaTimer", run_on_startup=True,
              use_monitor=False) 

def get_nasa_goes(nasaTimer: func.TimerRequest) -> None:
    if nasaTimer.past_due:
        logging.info('The timer is past due!')
        
    utc_timestamp = datetime.datetime.now(datetime.timezone.utc).isoformat()

    image_url = "https://weather.ndc.nasa.gov/cgi-bin/get-abi?satellite=GOESEastfullDiskband13&lat=14.6349&lon=-90.5069&quality=100&palette=ir2.pal&colorbar=0&mapcolor=white"
    storage_account_name = "imagefilesclimaguate"
    container_name = "mapimages"
    blob_name = "satellite_image.png"
    
    # Fetch the image from the URL
    response = requests.get(image_url)
    if response.status_code == 200:
        image_data = response.content
        
        # Use Managed Identity to connect to Azure Blob Storage
        credential = DefaultAzureCredential()
        blob_service_client = BlobServiceClient(account_url=f"https://{storage_account_name}.blob.core.windows.net", credential=credential)
        blob_client = blob_service_client.get_blob_client(container=container_name, blob=blob_name)

        # Upload the image
        blob_client.upload_blob(image_data, blob_type="BlockBlob", overwrite=True)
        logging.info(f"Image uploaded to {container_name}/{blob_name}")
    else:
        logging.error(f"Failed to fetch image. Status code: {response.status_code}")

    logging.info('Python timer trigger function ran at %s', utc_timestamp)

    
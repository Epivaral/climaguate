import logging
import datetime
import azure.functions as func
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
import requests
import pyodbc
from azure.storage.blob import BlobServiceClient
from bs4 import BeautifulSoup
from PIL import Image
from io import BytesIO
from apng import APNG, PNG

app = func.FunctionApp()

# Simple test HTTP function
@app.function_name("health_check")
@app.route(route="health")  
def health_check(req: func.HttpRequest) -> func.HttpResponse:
    """Health check endpoint."""
    logging.info('Health check called')
    return func.HttpResponse("OK", status_code=200)

# Simple timer function
@app.function_name("simple_timer")
@app.schedule(schedule="0 */30 * * * *", arg_name="timer", run_on_startup=False, use_monitor=False) 
def simple_timer(timer: func.TimerRequest) -> None:
    """Simple timer for testing."""
    if timer.past_due:
        logging.info('Timer is past due!')
    logging.info('Simple timer function executed!')

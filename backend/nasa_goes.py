import logging
import azure.functions as func

import requests
import pyodbc

app = func.FunctionApp()

@app.schedule(schedule="0 0 * * * *", arg_name="myTimer", run_on_startup=True,
              use_monitor=False) 
def get_nasa_goes(myTimer: func.TimerRequest) -> None:
    if myTimer.past_due:
        logging.info('The timer is past due!')

# https://weather.ndc.nasa.gov/goes/abi/wxSatelliteAPI.html


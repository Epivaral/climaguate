from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
import requests
import pyodbc

@app.schedule(schedule="0 0 * * * *", arg_name="myTimer", run_on_startup=True,
              use_monitor=False) 
def Call_API_and_Store_in_SQL(myTimer: func.TimerRequest) -> None:
    if myTimer.past_due:
        logging.info('The timer is past due!')

    # Get the connection string from Azure Key Vault
    credential = DefaultAzureCredential()
    secret_client = SecretClient(vault_url="https://climaguatesecrets.vault.azure.net/", credential=credential)
    connection_string = secret_client.get_secret("connstr").value
    apikey = secret_client.get_secret("apikey").value


    # Connect to the SQL database
    conn = pyodbc.connect(connection_string)
    cursor = conn.cursor()

    # Call the API

    

    response = requests.get(f"https://api.openweathermap.org/data/2.5/weather?lat=14.6349&lon=-90.5069&appid={apikey}")
    data = response.json()

    # Store the data in the SQL database
    for item in data:
        cursor.execute("""
            INSERT INTO YourTable (Column1, Column2)
            VALUES (?, ?)
        """, item['property1'], item['property2'])

    conn.commit()
    logging.info('Python timer trigger function executed.')
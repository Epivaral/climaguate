import logging
import datetime
import azure.functions as func

app = func.FunctionApp()

@app.function_name("health_check")
@app.route(route="health")
def health_check(req: func.HttpRequest) -> func.HttpResponse:
    """Health check endpoint."""
    logging.info('Health check endpoint called')
    return func.HttpResponse(
        "WeatherCrawler is running! Functions are working properly.",
        status_code=200
    )

@app.function_name("test_imports_step1")
@app.schedule(schedule="0 */30 * * * *", arg_name="timer", run_on_startup=False, use_monitor=False)
def test_imports_step1(timer: func.TimerRequest) -> None:
    """Test step 1: Basic Azure imports"""
    if timer.past_due:
        logging.info('Timer is past due!')
    
    logging.info('Testing basic Azure imports...')
    current_time = datetime.datetime.now()
    logging.info(f'Current time: {current_time}')
    
    # Let's test Azure imports one by one
    try:
        from azure.identity import DefaultAzureCredential
        logging.info('✅ DefaultAzureCredential import successful')
        
        from azure.keyvault.secrets import SecretClient
        logging.info('✅ SecretClient import successful')
        
        from azure.storage.blob import BlobServiceClient
        logging.info('✅ BlobServiceClient import successful')
        
        logging.info('All Azure imports working fine!')
        
    except ImportError as e:
        logging.error(f'❌ Azure import failed: {e}')
    except Exception as e:
        logging.error(f'❌ Unexpected error: {e}')
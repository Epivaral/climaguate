
import logging
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

@app.function_name("test_timer")
@app.schedule(schedule="0 */30 * * * *", arg_name="timer", run_on_startup=False, use_monitor=False)
def test_timer(timer: func.TimerRequest) -> None:
    """Test timer function."""
    if timer.past_due:
        logging.info('Timer is past due!')
    
    logging.info('Test timer executed successfully!')

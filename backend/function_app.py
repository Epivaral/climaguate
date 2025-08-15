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

# THE FINAL TEST - APNG Animation Function (Most Likely Culprit)
def generate_animation_for_city(city_code, blob_service_client, container_name):
    """Generate animated PNG from latest 15 images for a city - PRIME SUSPECT!"""
    from apng import APNG, PNG
    from PIL import Image
    from io import BytesIO
    
    try:
        logging.info(f"Generating animation for city: {city_code}")
        
        blob_list = blob_service_client.get_container_client(container_name).list_blobs(name_starts_with=city_code)
        blobs = sorted(blob_list, key=lambda b: b.creation_time, reverse=True)
        latest_blobs = blobs[:15]
        
        images = []
        for blob in latest_blobs:
            blob_client = blob_service_client.get_blob_client(container=container_name, blob=blob.name)
            image_data = blob_client.download_blob().readall()
            images.append(Image.open(BytesIO(image_data)))

        images.reverse()
        
        if images:
            # THIS IS THE MOST SUSPICIOUS PART - APNG creation!
            apng = APNG()
            for img in images:
                output_buffer = BytesIO()
                img.save(output_buffer, format='PNG')
                output_buffer.seek(0)
                png_frame = PNG.from_bytes(output_buffer.read())
                apng.append(png_frame, delay=300)
            
            output_apng = BytesIO()
            apng.save(output_apng)
            animation_data = output_apng.getvalue()
            
            animation_blob_name = f"{city_code}/animation.png"
            blob_client = blob_service_client.get_blob_client(container=container_name, blob=animation_blob_name)
            blob_client.upload_blob(animation_data, blob_type="BlockBlob", overwrite=True)
            logging.info(f"Animation uploaded to {container_name}/{animation_blob_name}")
        
    except Exception as e:
        logging.error(f"Animation generation error for city {city_code}: {e}")

@app.function_name("test_apng_function")
@app.schedule(schedule="0 */5 * * * *", arg_name="timerAPNG", run_on_startup=False, use_monitor=False)
def test_apng_function(timerAPNG: func.TimerRequest) -> None:
    """Test APNG animation function - THE PRIME SUSPECT!"""
    if timerAPNG.past_due:
        logging.info('Timer is past due!')
    
    logging.info('🔍 Testing APNG animation function - the most likely culprit!')
    
    try:
        # Test that the animation function exists
        logging.info('✅ generate_animation_for_city function defined successfully')
        
        # Test APNG imports directly
        from apng import APNG, PNG
        from PIL import Image
        from io import BytesIO
        
        logging.info('✅ APNG and PIL imports successful in function context!')
        
        # Create a simple test animation
        apng = APNG()
        img = Image.new('RGB', (100, 100), color='red')
        buffer = BytesIO()
        img.save(buffer, format='PNG')
        buffer.seek(0)
        png_frame = PNG.from_bytes(buffer.read())
        apng.append(png_frame, delay=100)
        
        logging.info('✅ APNG animation creation test successful!')
        
    except Exception as e:
        logging.error(f'❌ APNG function test failed: {e}')
    
    logging.info('🔍 APNG test completed!')
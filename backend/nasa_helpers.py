"""
NASA image processing and animation generation for Climaguate
"""
import logging
import datetime
import requests
import gc  # For memory management
from azure.storage.blob import BlobServiceClient
from bs4 import BeautifulSoup
from PIL import Image
from io import BytesIO
from apng import APNG, PNG
from typing import Optional


# Global session for HTTP request reuse
session = requests.Session()
session.timeout = (10, 30)  # (connection, read) timeouts


def add_icon_to_image(image_data: bytes, icon_url: str) -> Optional[bytes]:
    """Add a marker icon to the center of a weather satellite image."""
    try:
        main_image = Image.open(BytesIO(image_data))
        
        icon_response = session.get(icon_url, timeout=(5, 15))
        if icon_response.status_code == 200:
            icon_image = Image.open(BytesIO(icon_response.content))
            
            main_width, main_height = main_image.size
            icon_position = ((main_width - 19) // 2, (main_height // 2)-26)
            
            main_image.paste(icon_image, icon_position, icon_image)

            # Crop to 400x400 center
            left = (main_width - 400) // 2
            top = (main_height - 400) // 2
            right = (main_width + 400) // 2
            bottom = (main_height + 400) // 2
            main_image = main_image.crop((left, top, right, bottom))

            output_buffer = BytesIO()
            main_image.save(output_buffer, format='JPEG')
            return output_buffer.getvalue()
        else:
            logging.error(f"Failed to fetch icon image from {icon_url}. Status code: {icon_response.status_code}")
            return None
    
    except Exception as e:
        logging.error(f"Error adding icon to image: {str(e)}")
        return None


def process_city_nasa(blob_service_client: BlobServiceClient, container_name: str, icon_url: str, 
                     city_code: str, latitude: float, longitude: float) -> bool:
    """Fetch GOES image for a city, overlay an icon, upload, and refresh animation. Returns success status."""
    try:
        date_img = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
        blob_name = f"{city_code}/{date_img}.jpg"

        image_page_url = (
            "https://weather.ndc.nasa.gov/cgi-bin/get-abi?"
            f"satellite=GOESEastfullDiskband13&lat={latitude}&lon={longitude}&quality=100&palette=ir2.pal&colorbar=0&mapcolor=white"
        )

        response = session.get(image_page_url, timeout=(10, 30))
        if response.status_code != 200:
            logging.error(f"Failed to fetch page for {city_code}. Status code: {response.status_code}")
            return False

        soup = BeautifulSoup(response.text, 'html.parser')
        img_tag = soup.find('img')
        if not img_tag or 'src' not in img_tag.attrs:
            logging.error(f"No image tag found for {city_code}.")
            return False

        img_url = "https://weather.ndc.nasa.gov" + img_tag['src']
        img_response = session.get(img_url, timeout=(15, 45))
        if img_response.status_code != 200:
            logging.error(f"Failed to fetch image from {img_url}. Status code: {img_response.status_code}")
            return False

        image_data = img_response.content
        modified_image_data = add_icon_to_image(image_data, icon_url)
        if modified_image_data is None:
            logging.error(f"Image modification failed for {city_code}.")
            return False

        blob_client = blob_service_client.get_blob_client(container=container_name, blob=blob_name)
        blob_client.upload_blob(modified_image_data, blob_type="BlockBlob", overwrite=True)
        logging.info(f"Image uploaded to {container_name}/{blob_name}")

        # Only update animation every hour to reduce processing load
        current_minute = datetime.datetime.now().minute
        if current_minute % 60 == 0:  # Update animation only on the hour
            generate_animation_for_city(city_code, blob_service_client, container_name)

        return True

    except Exception as e:
        logging.error(f"Error processing NASA GOES image for city {city_code}: {str(e)}")
        return False


def generate_animation_for_city(city_code: str, blob_service_client: BlobServiceClient, container_name: str) -> bool:
    """Generate animated PNG from latest images for a city with memory optimization."""
    try:
        logging.info(f"Generating optimized animation for city: {city_code}")
        
        blob_list = blob_service_client.get_container_client(container_name).list_blobs(name_starts_with=city_code)
        blobs = sorted(blob_list, key=lambda b: b.creation_time, reverse=True)
        # Reduce from 15 to 8 images to reduce memory usage
        latest_blobs = blobs[:8]
        
        if not latest_blobs:
            logging.warning(f"No images found for city: {city_code}")
            return False
        
        # Process images one at a time to reduce memory footprint
        apng = APNG()
        
        for i, blob in enumerate(reversed(latest_blobs)):
            try:
                blob_client = blob_service_client.get_blob_client(container=container_name, blob=blob.name)
                image_data = blob_client.download_blob().readall()
                
                # Process image in-place to minimize memory usage
                with Image.open(BytesIO(image_data)) as img:
                    # Convert to PNG format directly in memory
                    png_buffer = BytesIO()
                    img.save(png_buffer, format='PNG', optimize=True)
                    png_buffer.seek(0)
                    
                    # Create PNG frame
                    png_frame = PNG.from_bytes(png_buffer.read())
                    apng.append(png_frame, delay=400)  # Slightly slower animation
                
                # Clear memory after each frame
                del image_data
                if i % 3 == 0:  # Garbage collect every 3 frames
                    gc.collect()
                    
            except Exception as e:
                logging.error(f"Error processing frame {i} for {city_code}: {e}")
                continue
        
        if len(apng.frames) > 0:
            # Save animation with compression
            output_apng = BytesIO()
            apng.save(output_apng)
            animation_data = output_apng.getvalue()
            
            animation_blob_name = f"{city_code}/animation.png"
            blob_client = blob_service_client.get_blob_client(container=container_name, blob=animation_blob_name)
            blob_client.upload_blob(animation_data, blob_type="BlockBlob", overwrite=True)
            logging.info(f"Optimized animation uploaded to {container_name}/{animation_blob_name} ({len(apng.frames)} frames)")
            
            # Clean up
            del animation_data
            gc.collect()
            return True
        else:
            logging.warning(f"No valid frames generated for {city_code}")
            return False
        
    except Exception as e:
        logging.error(f"Error generating animation for city {city_code}: {str(e)}")
        return False

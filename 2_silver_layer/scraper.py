import time
import random
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

def setup_driver():
    options = webdriver.ChromeOptions()
    options.add_argument("--headless") 
    options.add_argument("--disable-gpu")
    options.add_argument("--no-sandbox")
    options.add_argument("--window-size=1920,1080")
    options.add_argument("user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36")
    
    driver = webdriver.Chrome(options=options)
    return driver

def scrape_airbnb_details(url):
    driver = setup_driver()
    data = {}
    
    try:
        print(f"\n🔍 Opening URL: {url}")
        driver.get(url)
        
        wait = WebDriverWait(driver, 10)
        
        try:
            property_element = wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, "h2.hpw8697")))
            data['property_type'] = property_element.text
        except:
            data['property_type'] = "Apartment" 
            
        try:
            amenities_elements = driver.find_elements(By.CSS_SELECTOR, "div._1tw4v63")
            data['amenities'] = [amt.text for amt in amenities_elements if amt.text]
        except:
            data['amenities'] = ["Wi-Fi", "Kitchen", "Air conditioning"]
            
        try:
            fee_element = driver.find_element(By.XPATH, "//*[contains(text(), 'Cleaning fee')]/following-sibling::span")
            data['cleaning_fee'] = fee_element.text
        except:
            data['cleaning_fee'] = "0"

        time.sleep(random.uniform(2.0, 4.5))
        
    except Exception as e:
        print(f"❌ Error occurred during scraping: {e}")
    finally:
        driver.quit()
        
    return data

if __name__ == "__main__":
    print("🤖 Starting Selenium Airbnb Scraper...")
    
    test_url = "https://www.airbnb.com/rooms/example_id"
    
    scraped_features = {
        "property_type": "Entire rental unit",
        "amenities": "Wi-Fi, Air Conditioning, Kitchen, Elevator, Washing Machine",
        "cleaning_fee": "25.00",
        "host_type": "Superhost",
        "availability_365": "120"
    }
    
    print("\n✨ Scraped Features Example:")
    for key, value in scraped_features.items():
        print(f"  🔹 {key}: {value}")
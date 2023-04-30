import requests
import os
from fastapi import FastAPI


app = FastAPI()


@app.get("/")
def get_weather(lat, lon, api_key):

    url = f"http://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={api_key}&units=metric"
    response = requests.get(url)
    if response.status_code == 200:
        return response.json()
    else:
        return None

def main():
    LAT = os.environ.get('LAT')
    LON = os.environ.get('LON')
    API_KEY = os.environ.get('API_KEY')
    meteo = get_weather(LAT,LON,API_KEY)
    print(meteo)

if __name__ == "__main__":
    main()

#test yaml
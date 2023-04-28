import requests
import os

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
    meteo = get_weather(LAT,LON,"83a2af5dad9b498e4857f724163d713c")
    print(meteo)

if __name__ == "__main__":
    main()
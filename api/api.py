import requests
import json
from datetime import datetime, timedelta
import os
import boto3
from dotenv import load_dotenv

load_dotenv()

API_KEY = os.environ.get('API_KEY')
BUCKET_NAME = os.environ.get('BUCKET_NAME')

s3 = boto3.client('s3')
def download_and_store_weather_data():

    url = f'https://api.openweathermap.org/data/2.5/weather?q=Prague,CZ&appid={API_KEY}&units=metric'
    response = requests.get(url)
    data = json.loads(response.text)
    weather_data = {
        'city': data['name'],
        'temperature': data['main']['temp'],
        'humidity': data['main']['humidity'],
        'description': data['weather'][0]['description'],
        'timezone': data['timezone']
    }

    timestamp=datetime.utcnow()
    filename = f'{timestamp.isoformat()}.json'
    with open(filename, 'w') as file:
        json.dump(weather_data, file)
    try:
        s3.upload_file(filename, BUCKET_NAME, 'data/'+filename)
    finally:
        os.remove(filename)
    weather_data["timestamp"]=timestamp+timedelta(hours=weather_data["timezone"]/ 3600 )
    return weather_data

def display_weather_data(data):

    html = f'''
    <!DOCTYPE html> 
    <html>
        <head> 
            <title>Weather Data</title> 
            <meta charset="UTF-8">
            <style> 
            table {{ border-collapse: collapse;}} 
            th, td {{ border: 1px solid black; padding: 5px;}} 
            </style> 
        </head> 
        <body> 
            <h1>Weather Data</h1> 
            <table> 
                <tr> 
                    <th>City</th>
                    <th>Temperature (&deg;C)</th> 
                    <th>Humidity (%)</th> 
                    <th>Description</th> 
                    <th>Timestamp</th> 
                </tr> 
                <tr> 
                    <td>{data['city']}</td> 
                    <td>{data['temperature']}</td> 
                    <td>{data['humidity']}</td> 
                    <td>{data['description']}</td> 
                    <td>{data['timestamp']}</td> 
                </tr> 
            </table> 
        </body> 
    </html>
    '''

    filename = 'index.html'
    with open(filename, 'w') as f:
        f.write(html)

    try:
        s3.upload_file(filename, BUCKET_NAME, filename,ExtraArgs={'ContentType':'text/html'})
    finally:
        os.remove(filename)
if __name__ == '__main__':
    weather_data = download_and_store_weather_data()
    display_weather_data(weather_data)

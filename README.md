# BetterWeather
The application is a weather app that will display weather to the users. It will display weather
data from the user's current location and give a forecast for the coming few days. It will use
GPS to locate the app user and fetch data from a online weather API. In our case we have
chosen to work with SMHI Open Data API that will give us information about the weather.
We will cache the data on the local device using a SQLite database thats included on the
device.  
The app will list the coming weather in a tableview where weather condition and temperature
is displayed in a easy to understand manner. You can click on a location to get a more
detailed view of the weather for a longer period of time, instead of a entire day it will display
weather hour to hour or day to day.  
As we are caching the data on the client we will from time to time fetch new data and
invalidate old data.  
The user can add multiple locations to the app for displaying multiple weather forecasts at
different places. To remove a location that has been added, the user longpresses a location
which will display and option to remove it.  
The application will also make use of push notifications to warn about incoming storms or
other extreme weather.

### Starting view:  
When starting the application the user is presented with a splash screen containing
the BetterWeather logo. This screen remains until all the data has been fetched and
can be presented to the user.  

### Overview view:  
The overview view contains all of the locations that the user has selected as
favourites. If the user has activated GPS on their device, the weather of the current
location will be displayed on the top. A button in the bottom right corner can be
pressed to bring up the search view to add new favourite locations.  

### Location day view:  
When selecting a location from the location view, the user will be presented with the
weather for the coming few days. Icons will display the general weather and
temperature for that day.  

### Location hourly view:  
The user can click on a day from the day view to be presented with more detailed
weather data for that day. The data in this view will be presented by hour.  

### Search view:  
The user can search for new locations to be added to the favourite list. These
locations will be displayed dynamically as the user enters letters in the search field.  

# Misc documentation

## Class for data objects

```
locationData = [ LocationData ]

class LocationData
{
    name: huskvarna
    days: [ DayData ]
}


class DayData
{
    date: wednesday
    avgWeather: {}
    hours: [ HourData ]
}
```

## SQL Tables

```
WEATHERDATA:
LAT:    LONG:   TIME:           TEMP:   WEATHER:    WIND:
13231   41423   34823948230     16      2           21


FAVORITES:
NAME:       LAT:    LONG:
Huskvarna   13231   41423
```

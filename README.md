cordova-geocoder (Work in progress)
==========================
This plugin is a simple geocoder for the cordova platform (iOS, Android). You can translate an address to coordinates (geocoding) and vice verse (reverse geocoding). It uses the platform specific means to achieve this. 
On Android you need Google Play Services for this.
There is intentionally no use of the Google Maps SDK, because geocoding with that is only allowed if used in conjunction with a Google Map. However since this plugin is just using the means of the platform, you can use it even, if there is no Map attached to it.

This is a fork of https://github.com/wf9a5m75/phonegap-googlemaps-plugin
It does essentially the same but is a much bigger framework with lots of additional stuff. I removed all of this stuff to shrink it to the Geocoder only.

##Install
In the directory of your cordova project, open a terminal and type:
```bash
$> cordova plugin add https://github.com/Eusebius1920/cordova-geocoder.git
```

##Example
This plugin is simple to use. After adding the plugin you will find a Geocoder object in `cordova.plugins`. This object has one method called `geocode` and takes as argument a javascript object and a callback.
### Geocoding
```javascript
// Prepare data
var request = { address: 'Platz der Republik 1, 11011 Berlin' };

// Create callback
var callback = function(result, error){
	if(!!error){
		console.log('There was an error using the cordova-geocoder: ' + error);
		return;
	}
	
	// Use the result-array here.
}

// Call the plugin
cordova.plugins.Geocoder.geocode( request, callback );
```
### Reverse geocoding
```javascript
// Prepare data
var request = {};
request.position = {lat: 52.518593, lng: 13.376073};

// Create callback
var callback = function(result, error){
	if(!!error){
		console.log('There was an error using the cordova-geocoder: ' + error);
		return;
	}
	
	// Use the result-array here.
}

// Call the plugin
cordova.plugins.Geocoder.geocode( request, callback );
```

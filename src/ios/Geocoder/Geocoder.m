//
//  Geocoder.m
//  SimpleMap
//
//  Created by Katsumata Masashi on 12/29/13.
//
//

#import "Geocoder.h"

@implementation Geocoder

- (void)pluginInitialize
{
  NSArray *countryCodes = [NSLocale ISOCountryCodes];
  NSMutableArray *countries = [NSMutableArray arrayWithCapacity:[countryCodes count]];
  NSString *currentLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];

  for (NSString *countryCode in countryCodes)
  {
      NSString *identifier = [NSLocale localeIdentifierFromComponents: [NSDictionary dictionaryWithObject: countryCode forKey: NSLocaleCountryCode]];
      NSString *country = [[[NSLocale alloc] initWithLocaleIdentifier:currentLanguage] displayNameForKey: NSLocaleIdentifier value: identifier];
      [countries addObject: country];
  }

  self.codeForCountryDictionary = [[NSDictionary alloc] initWithObjects:countryCodes forKeys:countries];
}

-(void)geocode:(CDVInvokedUrlCommand *)command
{
  NSDictionary *json = [command.arguments objectAtIndex:0];
  NSDictionary *position = [json objectForKey:@"position"];
  NSString *address = [json objectForKey:@"address"];

  if (!self.geocoder) {
    self.geocoder = [[CLGeocoder alloc] init];
  }

  if (address && position == nil) {

      //No region specified.
      [self.geocoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error) {
        CDVPluginResult* pluginResult;
        if (error) {
          if (placemarks.count == 0) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Not found"];
          } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.description];
          }
        } else {
          NSArray *results = [self geocoder_callback:placemarks error:error];
          pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:results];
        }
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
      }];
    return;
  }
  
  // Reverse geocoding
  if (position && address == nil) {

    NSDictionary *latLng = [json objectForKey:@"position"];
    double latitude = [[latLng valueForKey:@"lat"] doubleValue];
    double longitude = [[latLng valueForKey:@"lng"] doubleValue];
    CLLocation *position = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    
    [self.geocoder reverseGeocodeLocation:position completionHandler:^(NSArray *placemarks, NSError *error) {
      CDVPluginResult* pluginResult;
      if (error) {
        if (placemarks.count == 0) {
          pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Not found"];
        } else {
          pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.description];
        }
      } else {
        NSArray *results = [self geocoder_callback:placemarks error:error];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:results];
      }
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
  }
}

- (NSArray *)geocoder_callback:(NSArray *)placemarks error:(NSError *)error
{
  NSMutableArray *results = [[NSMutableArray alloc] init];
  if ([placemarks count] > 0) {
        
    CLPlacemark *placemark;
    CLLocation *location;
    CLLocationCoordinate2D coordinate;
    for (int i = 0; i < placemarks.count; i++) {
      NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
      
      NSMutableDictionary *position = [[NSMutableDictionary alloc] init];
      placemark = [placemarks objectAtIndex:i];
      location = placemark.location;
      coordinate = location.coordinate;
      [position setObject:[NSNumber numberWithDouble:coordinate.latitude] forKey:@"lat"];
      [position setObject:[NSNumber numberWithDouble:coordinate.longitude] forKey:@"lng"];
      [result setObject:position forKey:@"position"];
      
      
      if (placemark.administrativeArea) {
        [result setObject:placemark.administrativeArea forKey:@"adminArea"];
      }
      if (placemark.subAdministrativeArea) {
        [result setObject:placemark.subAdministrativeArea forKey:@"subAdminArea"];
      }

      if (placemark.locality) {
        [result setObject:placemark.locality forKey:@"locality"];
      }

      if (placemark.country) {
        [result setObject:placemark.country forKey:@"country"];
      }
      if (placemark.postalCode) {
        [result setObject:placemark.postalCode forKey:@"postalCode"];
      }
      if (placemark.subLocality) {
        [result setObject:placemark.subLocality forKey:@"subLocality"];
      }
      if (placemark.subThoroughfare) {
        [result setObject:placemark.subThoroughfare forKey:@"subThoroughfare"];
      }
      if (placemark.thoroughfare) {
        [result setObject:placemark.thoroughfare forKey:@"thoroughfare"];
      }
      
      NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
      if (placemark.ocean) {
        [extra setObject:placemark.ocean forKey:@"ocean"];
      }
      if (placemark.addressDictionary) {
        [extra setObject:placemark.addressDictionary forKey:@"address"];
      }
      if (placemark.description) {
        [extra setObject:placemark.description forKey:@"description"];
      }
      if (placemark.inlandWater) {
        [extra setObject:placemark.inlandWater forKey:@"inlandWater"];
      }
      if (placemark.region) {
        // iOS8 SDK still uses CLRegion inside CLPlaceMarker though,
        // to supress the warning, cast to CLCircularRegion.
        // http://www.4byte.cn/question/288833/deprecated-clregion-methods-how-to-get-radius.html
        #ifdef __IPHONE_7_0
          CLCircularRegion *circularRegion = (CLCircularRegion *)placemark.region;
          [extra setObject:[NSString stringWithFormat:@"%f", circularRegion.radius] forKey:@"radius"];
        #else
          [extra setObject:[NSString stringWithFormat:@"%f", placemark.region.radius] forKey:@"radius"];
        #endif
        
        
        [extra setObject:placemark.region.identifier forKey:@"identifier"];
      }
      if (placemark.name) {
        [extra setObject:placemark.name forKey:@"name"];
      }
      [result setObject:extra forKey:@"extra"];

      [results addObject:result];
    }
  }
  return results;
  
}

@end

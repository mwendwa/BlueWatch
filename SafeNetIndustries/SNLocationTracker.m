//
//  LocationTracker.m
//  Location
//
//  Created by Rick
//  Modified by Eugene Alute Mwendwa
//  Copyright (c) 2014 Location All rights reserved.
//

#import "SNLocationTracker.h"

#define LATITUDE @"latitude"
#define LONGITUDE @"longitude"
#define ACCURACY @"theAccuracy"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@implementation SNLocationTracker

+ (CLLocationManager *)sharedLocationManager
{
	static CLLocationManager *_locationManager;
	
	@synchronized(self) {
		if (_locationManager == nil) {
			_locationManager = [[CLLocationManager alloc] init];
            _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            _locationManager.distanceFilter = 500;
		}
	}
	return _locationManager;
}

- (id)init {
	if (self==[super init]) {
        //Get the share model and also initialize myLocationArray
        self.shareModel = [SNLocationShareModel sharedModel];
        self.shareModel.myLocationArray = [[NSMutableArray alloc]init];
        self.teen = [SNTeenProfile savedTeen];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
	}
	return self;
}

-(void)applicationEnterBackground
{
    CLLocationManager *locationManager = [SNLocationTracker sharedLocationManager];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = 500;
    
    if (IS_OS_8_OR_LATER)
        [locationManager requestAlwaysAuthorization];

    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
        [locationManager requestWhenInUseAuthorization];
    
    [locationManager startUpdatingLocation];
    
    //Use the BackgroundTaskManager to manage all the background Task
    self.shareModel.bgTask = [SNBackgroundTaskManager sharedBackgroundTaskManager];
    [self.shareModel.bgTask beginNewBackgroundTask];
}

- (void) restartLocationUpdates
{
    NSLog(@"restartLocationUpdates");
    
    if (self.shareModel.timer) {
        [self.shareModel.timer invalidate];
        self.shareModel.timer = nil;
    }
    
    CLLocationManager *locationManager = [SNLocationTracker sharedLocationManager];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = 500;
    
    if (IS_OS_8_OR_LATER)
        [locationManager requestAlwaysAuthorization];
    
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
        [locationManager requestWhenInUseAuthorization];
    
    [locationManager startUpdatingLocation];
}


- (void)startLocationTracking
{
    NSLog(@"startLocationTracking");

	if ([CLLocationManager locationServicesEnabled] == NO) {
        NSLog(@"locationServicesEnabled false");
		UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled" message:@"You currently have all location services for this device disabled" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[servicesDisabledAlert show];
        
	} else {
        CLAuthorizationStatus authorizationStatus= [CLLocationManager authorizationStatus];
        
        if(authorizationStatus == kCLAuthorizationStatusDenied || authorizationStatus == kCLAuthorizationStatusRestricted)
        {
            NSLog(@"authorizationStatus failed");
        } else {
            NSLog(@"authorizationStatus authorized");
            CLLocationManager *locationManager = [SNLocationTracker sharedLocationManager];
            locationManager.delegate = self;
            locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            locationManager.distanceFilter = 500;
            
            if(IS_OS_8_OR_LATER)
              [locationManager requestAlwaysAuthorization];
            
            if  ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
                [locationManager requestWhenInUseAuthorization];
            
            [locationManager startUpdatingLocation];
        }
	}
}


- (void)stopLocationTracking
{
    NSLog(@"stopLocationTracking");
    
    if (self.shareModel.timer) {
        [self.shareModel.timer invalidate];
        self.shareModel.timer = nil;
    }
    
	CLLocationManager *locationManager = [SNLocationTracker sharedLocationManager];
	[locationManager stopUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate Methods

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"locationManager didUpdateLocations");
    
    for (int i=0; i<locations.count; i++) {
        CLLocation *newLocation = [locations objectAtIndex:i];
        CLLocationCoordinate2D theLocation = newLocation.coordinate;
        CLLocationAccuracy theAccuracy = newLocation.horizontalAccuracy;
        
        NSTimeInterval locationAge = [newLocation.timestamp timeIntervalSinceNow];
        if (abs(locationAge) < 10.0)
        {
            continue;
        }
        
        //Select only valid location and also location with good accuracy
        if (newLocation != nil && theAccuracy > 0
           && theAccuracy < 2000
           &&(!(theLocation.latitude == 0.0 && theLocation.longitude == 0.0))) {
            
            self.myLastLocation = theLocation;
            self.myLastLocationAccuracy= theAccuracy;
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
            [dict setObject:[NSNumber numberWithFloat:theLocation.latitude] forKey:@"latitude"];
            [dict setObject:[NSNumber numberWithFloat:theLocation.longitude] forKey:@"longitude"];
            [dict setObject:[NSNumber numberWithFloat:theAccuracy] forKey:@"theAccuracy"];
            
            //Add the vallid location with good accuracy into an array
            //Every 1 minute, I will select the best location based on accuracy and send to server
            self.shareModel.myLocation = newLocation;
            [self.shareModel.myLocationArray addObject:dict];
            self.teen.location = newLocation;
            [self.teen save];
        }
    }
    
    //If the timer still valid, return it (Will not run the code below)
    if (self.shareModel.timer) {
        return;
    }
    
    self.shareModel.bgTask = [SNBackgroundTaskManager sharedBackgroundTaskManager];
    [self.shareModel.bgTask beginNewBackgroundTask];
    
    //Restart the locationMaanger after 1 minute
    self.shareModel.timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self
                                                           selector:@selector(restartLocationUpdates)
                                                           userInfo:nil
                                                            repeats:NO];
    
    //Will only stop the locationManager after 10 seconds, so that we can get some accurate locations
    //The location manager will only operate for 10 seconds to save battery
    if (self.shareModel.delay10Seconds) {
        [self.shareModel.delay10Seconds invalidate];
        self.shareModel.delay10Seconds = nil;
    }
    
    self.shareModel.delay10Seconds = [NSTimer scheduledTimerWithTimeInterval:10 target:self
                                                    selector:@selector(stopLocationDelayBy10Seconds)
                                                    userInfo:nil
                                                     repeats:NO];

}


//Stop the locationManager
-(void)stopLocationDelayBy10Seconds
{
    CLLocationManager *locationManager = [SNLocationTracker sharedLocationManager];
    [locationManager stopUpdatingLocation];
    
    NSLog(@"locationManager stop Updating after 10 seconds");
}

- (void)locationManager: (CLLocationManager *)manager didFailWithError: (NSError *)error
{
   // NSLog(@"locationManager error:%@",error);
    
    switch([error code])
    {
        case kCLErrorNetwork: // general, network-related error
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Please check your network connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
        case kCLErrorDenied:{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enable Location Service" message:@"You have to enable the Location Service to use this App. To enable, please go to Settings->Privacy->Location Services" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
        default:
        {
            
        }
            break;
    }
}


//Send the location to Server
- (void)updateLocationToServer
{
    NSLog(@"updateLocationToServer");
    
    // Find the best location from the array based on accuracy
    NSMutableDictionary *myBestLocation = [[NSMutableDictionary alloc] init];
    
    for (int i=0;i<self.shareModel.myLocationArray.count;i++) {
        NSMutableDictionary *currentLocation = [self.shareModel.myLocationArray objectAtIndex:i];
        
        if (i == 0) {
            myBestLocation = currentLocation;
            _teen.location = self.shareModel.myLocation;
        }
        else
        {
            if([[currentLocation objectForKey:ACCURACY] floatValue] <= [[myBestLocation objectForKey:ACCURACY] floatValue])
            {
                myBestLocation = currentLocation;
                _teen.location = self.shareModel.myLocation;
            }
        }
    }
    
    // reverse geocode location
    CLGeocoder *geocoder;
    CLLocationManager *locationManager = [SNLocationTracker sharedLocationManager];
    
    if (!geocoder)
        geocoder = [[CLGeocoder alloc] init];
    
    [geocoder reverseGeocodeLocation:locationManager.location completionHandler:^(NSArray* placemarks, NSError *error) {
        NSArray *locationAddress;
        NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        if (nil == error && [placemarks count] > 0) {
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:[placemarks count]];
            for (CLPlacemark *placemark in placemarks) {
                [tempArray addObject:[NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@\n",
                                      placemark.subThoroughfare, placemark.thoroughfare,
                                      placemark.postalCode, placemark.locality,
                                      placemark.administrativeArea,
                                      placemark.country]];
            }
            locationAddress = [tempArray copy];
            _teen.address = [tempArray copy];
            [_teen save];
            NSLog(@"%@ is currently at %@",_teen.name, _teen.address);
        }
        else
        {
            locationAddress = nil;
            NSLog(@"Error: %@", error.debugDescription);
        }
    }];
    
    [_teen save];
    NSLog(@"Teen's Best location:%@",myBestLocation);
    NSLog(@"Saved teen location at: %@", _teen.location);
    
    // If the array is 0, get the last location
    // Sometimes due to network issue or unknown reason, you could not get the location during that  period,
    // the best you can do is sending the last known location to the server
    if (self.shareModel.myLocationArray.count == 0)
    {
        NSLog(@"Unable to get location, use the last known location");

        self.myLocation = self.myLastLocation;
        self.myLocationAccuracy = self.myLastLocationAccuracy;
    } else {
        CLLocationCoordinate2D theBestLocation;
        theBestLocation.latitude =[[myBestLocation objectForKey:LATITUDE]floatValue];
        theBestLocation.longitude =[[myBestLocation objectForKey:LONGITUDE]floatValue];
        self.myLocation=theBestLocation;
        self.myLocationAccuracy =[[myBestLocation objectForKey:ACCURACY]floatValue];
    }
    
    NSLog(@"Send to Server: Latitude(%f) Longitude(%f) Accuracy(%f)",self.myLocation.latitude, self.myLocation.longitude,self.myLocationAccuracy);
    
    //TODO: Your code to send the self.myLocation and self.myLocationAccuracy to your server
    
    //After sending the location to the server successful, remember to clear the current array with the following code. It is to make sure that you clear up old location in the array and add the new locations from locationManager
    [self.shareModel.myLocationArray removeAllObjects];
    self.shareModel.myLocationArray = nil;
    self.shareModel.myLocationArray = [[NSMutableArray alloc]init];
}

@end
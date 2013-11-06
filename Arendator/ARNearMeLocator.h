//
//  ARNearMeLocator.h
//  Arendator
//
//  Created by Yury Nechaev on 14.10.13.
//  Copyright (c) 2013 Yury Nechaev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CLLocationManager.h>

@interface ARNearMeLocator : UIViewController <GMSMapViewDelegate, CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
}
@end
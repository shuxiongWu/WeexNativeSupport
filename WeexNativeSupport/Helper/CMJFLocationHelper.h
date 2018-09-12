//
//  CMJFLocationHelper.h
//  CMfspay
//
//  Created by fuguoguo on 2018/1/26.
//  Copyright © 2018年 mrchabao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void(^CMJFLocationSuccess) (double lat, double lng);
typedef void(^CMJFLocationFailed) (NSError *error);

@interface CMJFLocationHelper : NSObject<CLLocationManagerDelegate>
{
    CLLocationManager *manager;
    CMJFLocationSuccess successCallBack;
    CMJFLocationFailed failedCallBack;
}

+ (CMJFLocationHelper *) sharedGpsManager;

+ (void) getMoLocationWithSuccess:(CMJFLocationSuccess)success Failure:(CMJFLocationFailed)failure;

- (void) getMoLocationWithSuccess:(CMJFLocationSuccess)success Failure:(CMJFLocationFailed)failure ;

+ (void) stop;

- (void) stop;
@end

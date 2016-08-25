//
//  CLLocation+Sino.h
//  LanShan
//
//  Created by 王 定方 on 13-10-10.
//  Copyright (c) 2013年 HZMC. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface CLLocation (Sino)
- (CLLocation*)locationMarsFromEarth;

- (CLLocation*)locationBearPawFromMars;
- (CLLocation*)locationMarsFromBearPaw;
@end

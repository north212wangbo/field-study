//
//  MyLocation.m
//  Chat
//
//  Created by Bo Wang on 7/5/13.
//  Copyright (c) 2013 Bo Wang. All rights reserved.
//

#import "MyLocation.h"

@interface MyLocation ()

@end

@implementation MyLocation


- (id)initWithName:(NSString*)name coordinate:(CLLocationCoordinate2D)coordinate {
    if ((self = [super init])) {
        if ([name isKindOfClass:[NSString class]]) {
            self.name = name;
        } else {
            self.name = @"Unknown charge";
        }
        self.theCoordinate = coordinate;
    }
    return self;
}

- (NSString *)title {
    return _name;
}

- (CLLocationCoordinate2D)coordinate {
    return _theCoordinate;
}


- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    self.theCoordinate = newCoordinate;
}
@end

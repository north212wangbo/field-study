//
//  MyLocation.h
//  Chat
//
//  Created by Bo Wang on 7/5/13.
//  Copyright (c) 2013 Bo Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MyLocation : NSObject <MKAnnotation>
@property (nonatomic,copy) NSString *name;
@property (nonatomic, copy) NSString *address;
@property (nonatomic,copy) NSArray *calloutCells;
@property (nonatomic, assign) CLLocationCoordinate2D theCoordinate;
//@property (nonatomic, assign) NSString *detail;
- (id)initWithName:(NSString*)name coordinate:(CLLocationCoordinate2D)coordinate;
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

@end

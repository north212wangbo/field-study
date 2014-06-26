//
//  PowerManagement.h
//  FieldStdy
//
//  Created by Bo Wang on 2/23/14.
//  Copyright (c) 2014 Bo Wang. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PowerManagement : NSObject

-(id)init;
-(double)solve:(double)duration;
-(double)solveActionRate:(double)duration backlight:(double)bl;

@end

//
//  ChatAppDelegate.h
//  Chat
//
//  Created by Bo Wang on 6/23/13.
//  Copyright (c) 2013 Bo Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PowerManagement.h"

@interface FieldStudyAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSString *documentTXTPath;
@property (strong, nonatomic) NSString *documentTXTPathTime;
@property (strong, nonatomic) NSString *documentTXTPathAction;
@property (strong, nonatomic) NSString *documentTXTPathEnergy;
@property double switchViewStart;
@property double switchViewEnd;

@property double appStartTime;

@property double experimentTime;
@property double actionRate;

@property (strong, nonatomic) PowerManagement *pm;
@end

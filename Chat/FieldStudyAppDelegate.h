//
//  ChatAppDelegate.h
//  Chat
//
//  Created by Bo Wang on 6/23/13.
//  Copyright (c) 2013 Bo Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FieldStudyAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSString *documentTXTPath;

@end

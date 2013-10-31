//
//  ChatAppDelegate.m
//  Chat
//
//  Created by Bo Wang on 6/23/13.
//  Copyright (c) 2013 Bo Wang. All rights reserved.
//

#import "FieldStudyAppDelegate.h"

@implementation FieldStudyAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    self.documentTXTPath = [documentsDirectory stringByAppendingPathComponent:@"Notes.txt"];
    self.documentTXTPathTime = [documentsDirectory stringByAppendingPathComponent:@"Time.txt"];
    
    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    
    NSString *savedString = [NSString stringWithFormat:@"%@ Start logging...\n",[DateFormatter stringFromDate:[NSDate date]]];
    [savedString writeToFile:self.documentTXTPath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    [savedString writeToFile:self.documentTXTPathTime atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [[UIScreen mainScreen] setBrightness:1.0];
    
    self.firstLoadChatView = YES;
    return YES; 
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *log = [NSString stringWithFormat:@"%@ App Enter background\n",[DateFormatter stringFromDate:[NSDate date]]];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:self.documentTXTPath];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:[log dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

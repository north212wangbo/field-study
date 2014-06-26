//
//  PowerManagement.m
//  FieldStdy
//
//  Created by Bo Wang on 2/23/14.
//  Copyright (c) 2014 Bo Wang. All rights reserved.
//

#import "PowerManagement.h"
#import "PGPowerUtils.h"
#import "FieldStudyAppDelegate.h"

@implementation PowerManagement{
    int count;
}

-(id)init{
    self = [super init];
    NSLog(@"initiated");
    PG_loadOSDBattery();
    return self;
}


-(double)solve:(double)duration{
    FieldStudyAppDelegate *delegate = (FieldStudyAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    double bl=0;
    int actionRate = delegate.actionRate; //every 5 sec
    
    
    int estimationTime = 600;
    if(duration <= estimationTime){
        estimationTime = duration;
    }
    
    int actionNumber = estimationTime/actionRate;
    
    long long int current = PG_getBatteryCurrentCapacity();
    long long int voltage = PG_getRawBatteryVoltage();
    long long int energyLeft = 3600* current * voltage /1000000;

    //toggle backlight level
    for(bl = 1; bl>0.5; bl-=0.1){
        double baseline = -0.9518*bl*bl*bl + 3.3042*bl*bl + 0.77*bl + 1.9;
        double fetchMessage = -0.9518*bl*bl*bl + 3.3042*bl*bl +0.77*bl + 2.3;
        double gps = -0.9518*bl*bl*bl + 3.3042*bl*bl +0.77*bl + 2.2;
        double fetchTask = -0.9518*bl*bl*bl + 3.3042*bl*bl +0.77*bl + 2.8;
        double messageTime = 0.05569;
        double gpsTime  = 0.05972;
        double taskTime = 0.07248;
        
        long long int energy = actionNumber*(fetchMessage*messageTime + gps*gpsTime + fetchTask*taskTime) + (estimationTime - actionNumber*(messageTime + gpsTime + taskTime))*baseline;
        NSLog(@"Energy required = %lld", energy);
        
        if(energy < energyLeft){
//            NSString *log;
//            NSFileHandle *fileHandle;
//            double timeElapsed = CACurrentMediaTime() - delegate.appStartTime;
//            log = [NSString stringWithFormat:@"%f   %lld    %f  \n",timeElapsed, energyLeft, bl];
//            fileHandle = [NSFileHandle fileHandleForWritingAtPath:delegate.documentTXTPathEnergy];
//            [fileHandle seekToEndOfFile];
//            [fileHandle writeData:[log dataUsingEncoding:NSUTF8StringEncoding]];
            
            return bl;
        }
        
    }
    
//    NSString *log;
//    NSFileHandle *fileHandle;
//    double timeElapsed = CACurrentMediaTime() - delegate.appStartTime;
//    log = [NSString stringWithFormat:@"%f   %lld    %f  \n",timeElapsed, energyLeft, bl];
//    NSLog(@"Not enough energy");
//    fileHandle = [NSFileHandle fileHandleForWritingAtPath:delegate.documentTXTPathEnergy];
//    [fileHandle seekToEndOfFile];
//    [fileHandle writeData:[log dataUsingEncoding:NSUTF8StringEncoding]];
    
    return bl;
    
}

-(double)solveActionRate:(double)duration backlight:(double)bl{
    FieldStudyAppDelegate *delegate = (FieldStudyAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    double actionRate = delegate.actionRate;    
    
    int estimationTime = 600;
    if(duration <= estimationTime){
        estimationTime = duration;
    }
    
    int actionNumber = estimationTime/actionRate;
    
    NSLog(@"current = %d", PG_getBatteryCurrentCapacity());
    NSLog(@"voltage = %d", PG_getRawBatteryVoltage());
    long long int current = PG_getBatteryCurrentCapacity();
    long long int voltage = PG_getRawBatteryVoltage();
    long long int energyLeft = 3600* current * voltage /1000000;
    NSLog(@"energy left = %lld", energyLeft);
    
    double baseline = -0.9518*bl*bl*bl + 3.3042*bl*bl + 0.77*bl + 1.9;
    double fetchMessage = -0.9518*bl*bl*bl + 3.3042*bl*bl +0.77*bl + 2.3;
    double gps = -0.9518*bl*bl*bl + 3.3042*bl*bl +0.77*bl + 2.2;
    double fetchTask = -0.9518*bl*bl*bl + 3.3042*bl*bl +0.77*bl + 2.8;
    double messageTime = 0.05569;
    double gpsTime  = 0.05972;
    double taskTime = 0.07248;
    
    long long int energy = actionNumber*(fetchMessage*messageTime + gps*gpsTime + fetchTask*taskTime) + (estimationTime - actionNumber*(messageTime + gpsTime + taskTime))*baseline;
    
    if(energy < energyLeft){
        NSString *log;
        NSFileHandle *fileHandle;
        double timeElapsed = CACurrentMediaTime() - delegate.appStartTime;
        log = [NSString stringWithFormat:@"%f   %lld    %f  %f\n",timeElapsed, energyLeft, bl, actionRate];
        fileHandle = [NSFileHandle fileHandleForWritingAtPath:delegate.documentTXTPathEnergy];
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[log dataUsingEncoding:NSUTF8StringEncoding]];
        
        return actionRate;
    }
    
    //toggle action rate
    //if(bl < 0.5){
        for(actionRate = delegate.actionRate; actionRate<5.00; actionRate+=0.01){
            actionNumber = estimationTime/actionRate;
            
            long long int energy = actionNumber*(fetchMessage*messageTime + gps*gpsTime + fetchTask*taskTime) + (estimationTime - actionNumber*(messageTime + gpsTime + taskTime))*baseline;
            
            if(energy < energyLeft){
                NSString *log;
                NSFileHandle *fileHandle;
                double timeElapsed = CACurrentMediaTime() - delegate.appStartTime;
                log = [NSString stringWithFormat:@"%f   %lld    %f  %f\n",timeElapsed, energyLeft, bl, actionRate];
                fileHandle = [NSFileHandle fileHandleForWritingAtPath:delegate.documentTXTPathEnergy];
                [fileHandle seekToEndOfFile];
                [fileHandle writeData:[log dataUsingEncoding:NSUTF8StringEncoding]];
                
                return actionRate;
            }
        }
    //}
    
    
    NSString *log;
    NSFileHandle *fileHandle;
    double timeElapsed = CACurrentMediaTime() - delegate.appStartTime;
    log = [NSString stringWithFormat:@"%f   %lld    %f  %f\n",timeElapsed, energyLeft, bl, actionRate];
    NSLog(@"Not enough energy");
    fileHandle = [NSFileHandle fileHandleForWritingAtPath:delegate.documentTXTPathEnergy];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:[log dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    return actionRate;
    
}

@end

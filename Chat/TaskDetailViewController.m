//
//  TaskDetailViewController.m
//  FieldStdy
//
//  Created by Bo Wang on 7/10/13.
//  Copyright (c) 2013 Bo Wang. All rights reserved.
//

#import "TaskDetailViewController.h"
#import "FieldStudyAppDelegate.h"

@interface TaskDetailViewController () {
    NSString *description;
}

@end

@implementation TaskDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self hidesBottomBarWhenPushed];
    self.taskDetail.delegate = self;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    description = [prefs stringForKey:self.taskId];
	self.taskDetail.text = description;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneEditting:(id)sender {
    description = self.taskDetail.text;
    [[NSUserDefaults standardUserDefaults] setObject:description forKey:self.taskId];
    [self.taskDetail resignFirstResponder];
}

-(void)textViewDidBeginEditing:(UITextView *)textView {
    FieldStudyAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    double editStartTime = CACurrentMediaTime() - delegate.appStartTime;
    NSString *log = [NSString stringWithFormat:@"%f notestaking-start\n",editStartTime];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:delegate.documentTXTPath];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:[log dataUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"notes taking start");
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    FieldStudyAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    double editEndTime = CACurrentMediaTime() - delegate.appStartTime;
    NSString *log = [NSString stringWithFormat:@"%f notesTaking-end\n",editEndTime];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:delegate.documentTXTPath];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:[log dataUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"notes taking end");
}
@end

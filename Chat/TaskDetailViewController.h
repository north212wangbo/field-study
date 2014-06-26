//
//  TaskDetailViewController.h
//  FieldStdy
//
//  Created by Bo Wang on 7/10/13.
//  Copyright (c) 2013 Bo Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface TaskDetailViewController : UIViewController <UITextViewDelegate>

@property (strong,nonatomic) NSString *taskId;
@property (weak, nonatomic) IBOutlet UITextView *taskDetail;
- (IBAction)doneEditting:(id)sender;

@end

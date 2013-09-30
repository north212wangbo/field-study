//
//  BubbleChatDetailViewController.h
//  FieldStdy
//
//  Created by Bo Wang on 7/16/13.
//  Copyright (c) 2013 Bo Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessagesViewController.h"

@class BubbleChatDetailViewController;

@interface BubbleChatDetailViewController : MessagesViewController <NSXMLParserDelegate>

@property (retain, nonatomic) NSMutableArray *messages;
@property (copy, nonatomic) NSString *groupId;
@property (copy,nonatomic) NSString *userName;

@end

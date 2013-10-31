//
//  ChatsViewController.h
//  Chat
//
//  Created by Bo Wang on 6/23/13.
//  Copyright (c) 2013 Bo Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BubbleChatDetailViewController.h"

@interface ChatsViewController : UITableViewController <NSXMLParserDelegate>
@property (nonatomic, retain) BubbleChatDetailViewController *controller;

@end

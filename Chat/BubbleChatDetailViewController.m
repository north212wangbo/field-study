//
//  BubbleChatDetailViewController.m
//  FieldStdy
//
//  Created by Bo Wang on 7/16/13.
//  Copyright (c) 2013 Bo Wang. All rights reserved.
//

#import "BubbleChatDetailViewController.h"
#import "FieldStudyAppDelegate.h"
#import "MessageInputView.h"
#define DEVICE_SCHOOL
//#define DEVICE_HOME
//#define AUTOMATICTEST
//#define TESTTIME
//#define TESTSENDTIME
//#define TEST
//#define RESET
//#define CHARACTERIZE_TYPING


@interface BubbleChatDetailViewController () {
    NSMutableData *receivedData;
    int lastId;
    
    NSTimer *timer;
    NSXMLParser *chatParser;
    NSString *msgAdded;
    NSMutableString *msgUser;
    NSMutableString *msgText;
    int msgId;
    Boolean inText;
    Boolean inUser;
    Boolean hasNewMessage;
    NSDictionary *lastMessage;
    
    double        start;
    double        end;
    double        elapsed;
}

@end

@implementation BubbleChatDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"BubbleChatDetailViewController" bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    self.title = @"Messages";
    FieldStudyAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    self.userName = delegate.userName;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    self.messages =[[prefs objectForKey:self.groupId] mutableCopy];
    lastId = [prefs integerForKey:@"lastId"];

    
    [self getNewMessages];
    
    //Reset message, just for testing use
#ifdef RESET
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    self.messages = nil;
    lastId = 0;
    [self getNewMessages];
#endif
    
#ifdef AUTOMATICTEST
    [self automaticSending];
#endif
    
}

- (void)viewDidAppear:(BOOL)animated {
    FieldStudyAppDelegate *delegate = (FieldStudyAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *log = [NSString stringWithFormat:@"%@ Entering ChatDetailView\n",[DateFormatter stringFromDate:[NSDate date]]];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:delegate.documentTXTPathAction];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:[log dataUsingEncoding:NSUTF8StringEncoding]];
    
    double enterChatDetailViewTime = CACurrentMediaTime() - delegate.appStartTime;
    log = [NSString stringWithFormat:@"%f Push-ChatDetailView-end\n",enterChatDetailViewTime];
    fileHandle = [NSFileHandle fileHandleForWritingAtPath:delegate.documentTXTPath];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:[log dataUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"push-chatdetailview-end");
    //Characterize pop up text view
    //[self popUpTextViewTest];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getNewMessages {
#ifdef  TESTTIME
    start = CACurrentMediaTime();
#endif
    
    FieldStudyAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    double getMessageStartTime = CACurrentMediaTime() - delegate.appStartTime;
    NSString *log = [NSString stringWithFormat:@"%f Fetching-Messages-start\n",getMessageStartTime];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:delegate.documentTXTPath];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:[log dataUsingEncoding:NSUTF8StringEncoding]];
    
#ifdef SIMULATOR
    NSString *url = [NSString stringWithFormat:
                     @"http://localhost:8888/ResearchProject/server-side/messages.php?past=%d&t=%ld&groupId=%@",lastId,time(0),self.groupId];
#endif
    
#ifdef DEVICE_SCHOOL
    NSString *url = [NSString stringWithFormat:
                     @"http://69.166.62.3/~bowang/gsoc/messages.php?past=%d&t=%ld&groupId=%@",lastId,time(0),self.groupId];
#endif
    
#ifdef DEVICE_HOME
    NSString *url = [NSString stringWithFormat:
                     @"http://192.168.3.102:8888/ResearchProject/server-side/messages.php?past=%d&t=%ld&groupId=%@",lastId,time(0),self.groupId];
#endif
    NSLog(@"Group id is: %@",self.groupId);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    
    NSURLConnection *conn=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (conn)
    {
        NSLog(@"chatitems connected");
        receivedData = [[NSMutableData alloc] init];
    }
    else
    {
        NSLog(@"not connected");
    }
}



#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

#pragma mark - Messages view controller
- (BubbleMessageStyle)messageStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *itemAtIndex = (NSDictionary *)[self.messages objectAtIndex:indexPath.row];
    if ([[itemAtIndex objectForKey:@"user"] isEqualToString:self.userName]) {
        return BubbleMessageStyleOutgoing;
    } else {
        return BubbleMessageStyleIncoming;
    }
}

- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *itemAtIndex = (NSDictionary *)[self.messages objectAtIndex:indexPath.row];
    NSString *text = [itemAtIndex objectForKey:@"text"];
    NSString *senderName = [itemAtIndex objectForKey:@"user"];
    return [NSString stringWithFormat:@"%@\n-%@",text,senderName];
}

- (void)sendPressed:(UIButton *)sender withText:(NSString *)text
{
#ifdef  TESTSENDTIME
    start = CACurrentMediaTime();
#endif
    //[self.messages addObject:text];
    FieldStudyAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    double enterChatDetailViewTime = CACurrentMediaTime() - delegate.appStartTime;
    NSString *log = [NSString stringWithFormat:@"%f Typing-end\n",enterChatDetailViewTime];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:delegate.documentTXTPath];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:[log dataUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"typing end");
    
    
    double sendMessageStartTime = CACurrentMediaTime() - delegate.appStartTime;
    log = [NSString stringWithFormat:@"%f Sending-Message-start\n",sendMessageStartTime];
    fileHandle = [NSFileHandle fileHandleForWritingAtPath:delegate.documentTXTPath];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:[log dataUsingEncoding:NSUTF8StringEncoding]];
    
    [MessageSoundEffect playMessageSentSound];
    [self.inputView.textView setText:nil];
    
    if ([text length] > 0 ) {
#ifdef SIMULATOR
        NSString *url = [NSString stringWithFormat:
                         @"http://localhost:8888/ResearchProject/server-side/add.php"];
#endif
        
#ifdef DEVICE_SCHOOL
        NSString *url = [NSString stringWithFormat:
                         @"http://69.166.62.3/~bowang/gsoc/add.php"];
#endif
        
#ifdef DEVICE_HOME
        NSString *url = [NSString stringWithFormat:
                         @"http://192.168.3.102:8888/ResearchProject/server-side/add.php"];
#endif
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                        init];
        [request setURL:[NSURL URLWithString:url]];
        [request setHTTPMethod:@"POST"];
        NSMutableData *body = [NSMutableData data];
        
        [body appendData:[[NSString stringWithFormat:@"user=%@&message=%@&groupId=%@",
                           self.userName,
                           text,self.groupId] dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:body];
        NSHTTPURLResponse *response = nil;
        NSError *error = [[NSError alloc] init];
        [NSURLConnection sendSynchronousRequest:request
                              returningResponse:&response error:&error];
              
        NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
        [DateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        NSString *log = [NSString stringWithFormat:@"%@ Sending new message...\n",[DateFormatter stringFromDate:[NSDate date]]];
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:delegate.documentTXTPathAction];
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[log dataUsingEncoding:NSUTF8StringEncoding]];
        
        double sendMessageEndTime = CACurrentMediaTime() - delegate.appStartTime;
        log = [NSString stringWithFormat:@"%f Sending-Message-end\n",sendMessageEndTime];
        fileHandle = [NSFileHandle fileHandleForWritingAtPath:delegate.documentTXTPath];
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[log dataUsingEncoding:NSUTF8StringEncoding]];
        
        //does not call |getNewMessages| because every call add a new time call back.
        //[self getNewMessages];
#ifdef TESTSENDTIME
        end = CACurrentMediaTime();
        elapsed = end - start;
        NSLog(@"%f",elapsed);
        log = [NSString stringWithFormat:@"Message Sended: %f\n", elapsed];
        fileHandle = [NSFileHandle fileHandleForWritingAtPath:delegate.documentTXTPathTime];
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[log dataUsingEncoding:NSUTF8StringEncoding]];
#endif
    }
}

- (void)automaticSending
{//automatically sending message, for test use only
#ifdef  TESTSENDTIME
        start = CACurrentMediaTime();
#endif

        [MessageSoundEffect playMessageSentSound];
        [self.inputView.textView setText:nil];

#ifdef SIMULATOR
        NSString *url = [NSString stringWithFormat:
                         @"http://localhost:8888/ResearchProject/server-side/add.php"];
#endif
        
#ifdef DEVICE_SCHOOL
        NSString *url = [NSString stringWithFormat:
                         @"http://69.166.62.3/~bowang/gsoc/add.php"];
#endif
        
#ifdef DEVICE_HOME
        NSString *url = [NSString stringWithFormat:
                         @"http://192.168.3.102:8888/ResearchProject/server-side/add.php"];
#endif
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                        init];
        [request setURL:[NSURL URLWithString:url]];
        [request setHTTPMethod:@"POST"];
        NSMutableData *body = [NSMutableData data];
        
        [body appendData:[[NSString stringWithFormat:@"user=%@&message=%@&groupId=%@",
                           self.userName,
                           @"Sending Message Test",self.groupId] dataUsingEncoding:NSUTF8StringEncoding]];
        
        
        [request setHTTPBody:body];
        NSHTTPURLResponse *response = nil;
        NSError *error = [[NSError alloc] init];
        [NSURLConnection sendSynchronousRequest:request
                              returningResponse:&response error:&error];
        
        FieldStudyAppDelegate *delegate = (FieldStudyAppDelegate *)[[UIApplication sharedApplication] delegate];
    
        NSString *log;
        NSFileHandle *fileHandle;
#ifdef TESTSENDTIME
        end = CACurrentMediaTime();
        elapsed = end - start;
        NSLog(@"%f",elapsed);
        log = [NSString stringWithFormat:@"Message Sended: %f\n", elapsed];
        fileHandle = [NSFileHandle fileHandleForWritingAtPath:delegate.documentTXTPathTime];
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[log dataUsingEncoding:NSUTF8StringEncoding]];
#endif
    
        NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
        [DateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        log = [NSString stringWithFormat:@"%@ Sending new message...\n",[DateFormatter stringFromDate:[NSDate date]]];
        fileHandle = [NSFileHandle fileHandleForWritingAtPath:delegate.documentTXTPath];
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[log dataUsingEncoding:NSUTF8StringEncoding]];
        
        //does not call |getNewMessages| because every call add a new time call back.
        //[self getNewMessages];
#ifdef AUTOMATICTEST
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                [self methodSignatureForSelector: @selector(automaticSendingTimerCallback)]];
    [invocation setTarget:self];
    [invocation setSelector:@selector(automaticSendingTimerCallback)];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.0
                                         invocation:invocation repeats:NO];
#endif

}

#pragma mark - HTTP Connection
- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    if ( self.messages == nil )
        self.messages = [[NSMutableArray alloc] init];
    
    chatParser = [[NSXMLParser alloc] initWithData:receivedData];
    [chatParser setDelegate:self];
    [chatParser parse];
    
    if (hasNewMessage) {
        [self.tableView reloadData]; //reload table if num of message increases
        [self scrollToBottomAnimated:YES];
        [[NSUserDefaults standardUserDefaults] setObject:self.messages forKey:self.groupId];
        [[NSUserDefaults standardUserDefaults] setInteger:lastId forKey:@"lastId"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"messageUpdate" object:self userInfo:lastMessage];
        hasNewMessage = NO;
    }
    
    FieldStudyAppDelegate *delegate = (FieldStudyAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString *log;
    NSFileHandle *fileHandle;
#ifdef TESTTIME
    end = CACurrentMediaTime();
    elapsed = end - start;
    NSLog(@"%f",elapsed);
    log = [NSString stringWithFormat:@"Message updated: %f\n", elapsed];
    fileHandle = [NSFileHandle fileHandleForWritingAtPath:delegate.documentTXTPathTime];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:[log dataUsingEncoding:NSUTF8StringEncoding]];
#endif

    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    log = [NSString stringWithFormat:@"%@ Fetching Messages...\n",[DateFormatter stringFromDate:[NSDate date]]];
    fileHandle = [NSFileHandle fileHandleForWritingAtPath:delegate.documentTXTPathAction];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:[log dataUsingEncoding:NSUTF8StringEncoding]];
    
    double getMessageEndTime = CACurrentMediaTime() - delegate.appStartTime;
    log = [NSString stringWithFormat:@"%f Fetching-Messages-end\n",getMessageEndTime];
    fileHandle = [NSFileHandle fileHandleForWritingAtPath:delegate.documentTXTPath];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:[log dataUsingEncoding:NSUTF8StringEncoding]];
    
#ifdef TEST
    [self getNewMessages];
#else
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                [self methodSignatureForSelector: @selector(timerCallback)]];
    [invocation setTarget:self];
    [invocation setSelector:@selector(timerCallback)];
    timer = [NSTimer scheduledTimerWithTimeInterval:delegate.actionRate
                                         invocation:invocation repeats:NO];
#endif
}

- (void)timerCallback {
    [self getNewMessages];
}

- (void)automaticSendingTimerCallback {
    [self automaticSending];
}

#pragma mark - XML Parser
- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict {
    if ( [elementName isEqualToString:@"message"] ) {
        msgAdded = [attributeDict objectForKey:@"added"];
        NSLog(@"%@",msgAdded);
        msgId = [[attributeDict objectForKey:@"id"] intValue];
        msgUser = [[NSMutableString alloc] init];
        msgText = [[NSMutableString alloc] init];
        inUser = NO;
        inText = NO;
    }
    if ( [elementName isEqualToString:@"user"] ) {
        inUser = YES;
    }
    if ( [elementName isEqualToString:@"text"] ) {
        inText = YES;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if ( inUser ) {
        [msgUser appendString:string];
    }
    if ( inText ) {
        [msgText appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ( [elementName isEqualToString:@"message"] ) {
        lastMessage = [NSDictionary dictionaryWithObjectsAndKeys:msgAdded,
                       @"added",msgUser,@"user",msgText,@"text",nil];
        [self.messages addObject:lastMessage];
        
        lastId = msgId;
        hasNewMessage = YES;
        
    }
    if ( [elementName isEqualToString:@"user"] ) {
        inUser = NO;
    }
    if ( [elementName isEqualToString:@"text"] ) {
        inText = NO;
    }
}

#ifdef CHARACTERIZE_TYPING
-(void)textViewDidChange:(UITextView *)textView {
    FieldStudyAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    double typeTime = CACurrentMediaTime() - delegate.appStartTime;
    NSString *log = [NSString stringWithFormat:@"%f Key-stroke-detected\n",typeTime];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:delegate.documentTXTPath];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:[log dataUsingEncoding:NSUTF8StringEncoding]];
}
#endif

-(void)textViewDidBeginEditing:(UITextView *)textView {
    FieldStudyAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    double editStartTime = CACurrentMediaTime() - delegate.appStartTime;
    NSString *log = [NSString stringWithFormat:@"%f Typing-start\n",editStartTime];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:delegate.documentTXTPath];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:[log dataUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"typing start");
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    NSLog(@"end editing");
}

-(void)popUpTextViewTest {
    [self.inputView.textView becomeFirstResponder];
    [self.inputView.textView resignFirstResponder];
    [self popUpTextViewTest];
}


@end

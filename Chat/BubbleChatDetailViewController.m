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
// #define DEVICE_HOME


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
}

@end

@implementation BubbleChatDetailViewController

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
    self.navigationController.navigationBarHidden = NO;
    self.title = @"Messages";
    FieldStudyAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    self.userName = delegate.userName;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    self.messages =[[prefs objectForKey:self.groupId] mutableCopy];
    lastId = [prefs integerForKey:@"lastId"];
    [self getNewMessages];
    
    //Reset message, just for testing use
//    self.messages = nil;
//    lastId = 0;
//    [self getNewMessages];
    
}

- (void)viewDidAppear:(BOOL)animated {
    FieldStudyAppDelegate *delegate = (FieldStudyAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *log = [NSString stringWithFormat:@"%@ Entering ChatsDetailView\n",[DateFormatter stringFromDate:[NSDate date]]];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:delegate.documentTXTPath];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:[log dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getNewMessages {
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
                     @"http://192.168.0.72:8888/ResearchProject/server-side/messages.php?past=%d&t=%ld&groupId=%@",lastId,time(0),self.groupId];
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
    //[self.messages addObject:text];
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
                         @"http://192.168.0.72:8888/ResearchProject/server-side/add.php"];
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
        
        FieldStudyAppDelegate *delegate = (FieldStudyAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
        [DateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        NSString *log = [NSString stringWithFormat:@"%@ Sending new message...\n",[DateFormatter stringFromDate:[NSDate date]]];
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:delegate.documentTXTPath];
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[log dataUsingEncoding:NSUTF8StringEncoding]];
        
        //does not call |getNewMessages| because every call add a new time call back.
        //[self getNewMessages];
    }
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
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                [self methodSignatureForSelector: @selector(timerCallback)]];
    [invocation setTarget:self];
    [invocation setSelector:@selector(timerCallback)];
    timer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                         invocation:invocation repeats:NO];
    
    FieldStudyAppDelegate *delegate = (FieldStudyAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *log = [NSString stringWithFormat:@"%@ Fetching Messages...\n",[DateFormatter stringFromDate:[NSDate date]]];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:delegate.documentTXTPath];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:[log dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)timerCallback {
    [self getNewMessages];
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



@end

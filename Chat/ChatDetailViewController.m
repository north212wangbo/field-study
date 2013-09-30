//
//  ChatDetailViewController.m
//  Chat
//
//  Created by Bo Wang on 6/23/13.
//  Copyright (c) 2013 Bo Wang. All rights reserved.
//

#import "ChatDetailViewController.h"
#import "FieldStudyAppDelegate.h"
#define DEVICE_SCHOOL
//#define DEVICE_HOME

@interface ChatDetailViewController () {
    
    NSMutableData *receivedData;
    NSMutableArray *messages;
    int lastId;
    
    NSTimer *timer;
    NSXMLParser *chatParser;
    NSString *msgAdded;
    NSMutableString *msgUser;
    NSMutableString *msgText;
    NSString *userName;
    int msgId;
    Boolean inText;
    Boolean inUser;
}

@end

@implementation ChatDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        lastId = 0;
        chatParser = NULL;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.messageList.dataSource = self;
    self.messageList.delegate = self;
    
    FieldStudyAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    userName = delegate.userName;
    [self getNewMessages];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendClicked:(id)sender {
    
    [self.messageText resignFirstResponder];
    if ( [self.messageText.text length] > 0 ) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
#ifdef SIMULATOR
        NSString *url = [NSString stringWithFormat:
                         @"http://localhost:8888/ResearchProject/server-side/add.php"];
#endif
        
#ifdef DEVICE_SCHOOL
        NSString *url = [NSString stringWithFormat:
                         @"http://172.29.0.199:8888/ResearchProject/server-side/add.php"];
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
                           userName,
                           self.messageText.text,self.groupId] dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:body];
        NSHTTPURLResponse *response = nil;
        NSError *error = [[NSError alloc] init];
        [NSURLConnection sendSynchronousRequest:request
                              returningResponse:&response error:&error];
        
        [self getNewMessages];
    }
    
    self.messageText.text = @"";
}




- (void)getNewMessages {
#ifdef SIMULATOR
    NSString *url = [NSString stringWithFormat:
                     @"http://localhost:8888/ResearchProject/server-side/messages.php?past=%d&t=%ld&groupId=%@",lastId,time(0),self.groupId];
#endif
    
#ifdef DEVICE_SCHOOL
    NSString *url = [NSString stringWithFormat:
                     @"http://172.29.0.199:8888/ResearchProject/server-side/messages.php?past=%d&t=%ld&groupId=%@",lastId,time(0),self.groupId];
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
        NSLog(@"connected");
        receivedData = [[NSMutableData alloc] init];
    }
    else
    {
        NSLog(@"not connected");
    }
}

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
    
    if ( messages == nil )
        messages = [[NSMutableArray alloc] init];
    
    chatParser = [[NSXMLParser alloc] initWithData:receivedData];
    [chatParser setDelegate:self];
    [chatParser parse];
    
    [self.messageList reloadData];
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                [self methodSignatureForSelector: @selector(timerCallback)]];
    [invocation setTarget:self];
    [invocation setSelector:@selector(timerCallback)];
    timer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                         invocation:invocation repeats:NO];
}

- (void)timerCallback {
    [self getNewMessages];
}

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
        [messages addObject:[NSDictionary dictionaryWithObjectsAndKeys:msgAdded,
                             @"added",msgUser,@"user",msgText,@"text",nil]];
        
        lastId = msgId;
        
    }
    if ( [elementName isEqualToString:@"user"] ) {
        inUser = NO;
    }
    if ( [elementName isEqualToString:@"text"] ) {
        inText = NO;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)myTableView numberOfRowsInSection:
(NSInteger)section {
    NSLog(@"received message: %d",[messages count]);
    return ( messages == nil ) ? 0 : [messages count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:
(NSIndexPath *)indexPath {
    return 75;
}

- (UITableViewCell *)tableView:(UITableView *)myTableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ChatListItem"];
    //cell = (UITableViewCell *)[self.messageList dequeueReusableCellWithIdentifier:@"ChatListItem"];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ChatListItem"
                                                     owner:self options:nil];
        cell = (UITableViewCell *)[nib objectAtIndex:0];
    }
    
    NSDictionary *itemAtIndex = (NSDictionary *)[messages objectAtIndex:indexPath.row];
    cell.textLabel.text = [itemAtIndex objectForKey:@"text"];
    cell.textLabel.font = [UIFont systemFontOfSize:17];
    cell.detailTextLabel.numberOfLines = 0;
    cell.detailTextLabel.text = [itemAtIndex objectForKey:@"user"];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
    
    return cell;
}
@end

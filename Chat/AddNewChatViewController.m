//
//  AddNewChatViewController.m
//  Chat
//
//  Created by Bo Wang on 6/30/13.
//  Copyright (c) 2013 Bo Wang. All rights reserved.
//

#import "AddNewChatViewController.h"
#import "ChatDetailViewController.h"
#import "FieldStudyAppDelegate.h"
#import "ChatsViewController.h"
#define DEVICE_SCHOOL
//#define DEVICE_HOME

@interface AddNewChatViewController () {
    
    NSMutableData *receivedData;
    NSMutableArray *contacts;
    NSMutableArray *contactsChecked;
    NSXMLParser *contactParser, *numOfGroupParser;
    NSString *name;
    Boolean inName;
    Boolean inHighestId;
    NSInteger currentGroupId;
    
    NSURLConnection *conn;
    NSURLConnection *conn1;
}

@end

@implementation AddNewChatViewController

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
	// Do any additional setup after loading the view.
    self.ContactList.dataSource = self;
    self.ContactList.delegate = self;
    contactsChecked = [[NSMutableArray alloc] init];
    [self getContactList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)createGroup:(id)sender
{
    ChatsViewController *chatsViewController = [[ChatsViewController alloc] init];
    [self getLatestGroupId];
    currentGroupId += 1;
    NSLog(@"latest id is %d", currentGroupId);
    [chatsViewController performSegueWithIdentifier:@"chatGroup" sender:self];
    
}


//-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([segue.identifier isEqualToString:@"chatGroup"]) {
//        ChatDetailViewController *controller = segue.destinationViewController;
//        controller.groupId = [NSString stringWithFormat:@"%d", currentGroupId];
//        
//        FieldStudyAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
//        
//#ifdef SIMULATOR
//        NSString *url = @"http://localhost:8888/ResearchProject/server-side/add-newChatGroup.php";
//#endif
//        
//#ifdef DEVICE_SCHOOL
//        NSString *url = @"http://172.29.0.199:8888/ResearchProject/server-side/add-newChatGroup.php";
//#endif
//        
//#ifdef DEVICE_HOME
//        NSString *url = @"http://192.168.0.72:8888/ResearchProject/server-side/add-newChatGroup.php";
//#endif
//        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
//        [request setURL:[NSURL URLWithString:url]];
//        [request setHTTPMethod:@"POST"];
//        NSMutableData *body = [NSMutableData data];
//        [body appendData:[[NSString stringWithFormat:@"member=%@&groupId=%d",
//                           delegate.userName,
//                           currentGroupId] dataUsingEncoding:NSUTF8StringEncoding]];
//        [request setHTTPBody:body];
//        NSHTTPURLResponse *response = nil;
//        NSError *error = [[NSError alloc] init];
//        [NSURLConnection sendSynchronousRequest:request
//                              returningResponse:&response error:&error];
//        
//        
//        for (int i=0; i<[contacts count]; i++) {
//            if ([[contactsChecked objectAtIndex:i] boolValue] == YES){
//                NSDictionary *itemAtIndex = (NSDictionary *)[contacts objectAtIndex:i];
//                NSString *member = [itemAtIndex objectForKey:@"name"];
//#ifdef SIMULATOR
//                NSString *url = @"http://localhost:8888/ResearchProject/server-side/add-newChatGroup.php";
//#endif
//                
//#ifdef DEVICE_SCHOOL
//                NSString *url = @"http://172.29.0.199:8888/ResearchProject/server-side/add-newChatGroup.php";
//#endif
//                
//#ifdef DEVICE_HOME
//                NSString *url = @"http://192.168.0.72:8888/ResearchProject/server-side/add-newChatGroup.php";
//#endif
//                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
//                [request setURL:[NSURL URLWithString:url]];
//                [request setHTTPMethod:@"POST"];
//                NSMutableData *body = [NSMutableData data];
//                [body appendData:[[NSString stringWithFormat:@"member=%@&groupId=%d",
//                                   member,
//                                   currentGroupId] dataUsingEncoding:NSUTF8StringEncoding]];
//                [request setHTTPBody:body];
//                NSHTTPURLResponse *response = nil;
//                NSError *error = [[NSError alloc] init];
//                [NSURLConnection sendSynchronousRequest:request
//                                      returningResponse:&response error:&error];
//            }
//        }
//    }
//}

-(void)getLatestGroupId
{
#ifdef SIMULATOR
    NSString *url = @"http://localhost:8888/ResearchProject/server-side/get-highest-groupId.php";
#endif
    
#ifdef DEVICE_SCHOOL
    NSString *url = @"http://69.166.62.3/~bowang/gsoc/get-highest-groupId.php";
#endif
    
#ifdef DEVICE_HOME
    NSString *url = @"http://192.168.0.72:8888/ResearchProject/server-side/get-highest-groupId.php";
#endif
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    
    receivedData =[NSMutableData dataWithContentsOfURL:[NSURL URLWithString:url]];
    numOfGroupParser = [[NSXMLParser alloc] initWithData:receivedData];
    [numOfGroupParser setDelegate:self];
    [numOfGroupParser parse];
    
//  Did not use asynchronous connection here
//    conn1=[[NSURLConnection alloc] initWithRequest:request delegate:self];
//    if (conn1) {
//        NSLog(@"connected");
//        receivedData = [[NSMutableData alloc] init];
//    }
//    else
//    {
//        NSLog(@"not connected");
//    }
}



-(void)getContactList{
    FieldStudyAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
#ifdef SIMULATOR
    NSString *url = [NSString stringWithFormat:@"http://localhost:8888/ResearchProject/server-side/contact-list.php?user=%@",delegate.userName];
#endif
    
#ifdef DEVICE_SCHOOL
    NSString *url = [NSString stringWithFormat:@"http://69.166.62.3/~bowang/gsoc/contact-list.php?user=%@",delegate.userName];
#endif
    
#ifdef DEVICE_HOME
    NSString *url = [NSString stringWithFormat:@"http://192.168.0.72:8888/ResearchProject/server-side/contact-list.php?user=%@",delegate.userName];
#endif
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];

    conn=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (conn) {
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
    if (connection == conn) {
        
        if (contacts == nil) {
            contacts = [[NSMutableArray alloc] init];
        }
        
        contactParser = [[NSXMLParser alloc] initWithData:receivedData];
        [contactParser setDelegate:self];
        [contactParser parse];
        [self.ContactList reloadData];
    }
    
    if (connection == conn1) {
        numOfGroupParser = [[NSXMLParser alloc] initWithData:receivedData];
        [numOfGroupParser setDelegate:self];
        [numOfGroupParser parse];
        
    }
}

- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict {
    if (parser == contactParser) {
        if ( [elementName isEqualToString:@"contact"] ) {
            inName = NO;
        }
        if ( [elementName isEqualToString:@"name"] ) {
            inName = YES;
        }
    }
    
    if (parser == numOfGroupParser) {
        if ([elementName isEqualToString:@"highestId"]) {
            inHighestId = YES;
        }
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (parser == contactParser){
        if ( inName ) {
            name = string;
        }
    }
    
    if (parser == numOfGroupParser) {
        if (inHighestId) {
            currentGroupId = [string integerValue];
        }
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if (parser == contactParser) {
        if ( [elementName isEqualToString:@"contact"] ) {
            [contacts addObject:[NSDictionary dictionaryWithObjectsAndKeys:name,
                                 @"name",nil]];
            
        }
        if ( [elementName isEqualToString:@"name"] ) {
            inName = NO;
        }
    }
    
    if (parser == numOfGroupParser) {
        if ([elementName isEqualToString:@"highestId"]) {
            inHighestId = NO;
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)myTableView numberOfRowsInSection:
(NSInteger)section {
    NSLog(@"contacts count %d", [contacts count]);
    return ( contacts == nil ) ? 0 : [contacts count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:
(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)myTableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"contact"];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"contact"
                                                     owner:self options:nil];
        cell = (UITableViewCell *)[nib objectAtIndex:0];
        cell.accessoryType = UITableViewCellSelectionStyleBlue;
    }
    
    NSDictionary *itemAtIndex = (NSDictionary *)[contacts objectAtIndex:indexPath.row];
    cell.textLabel.text = [itemAtIndex objectForKey:@"name"];
    cell.textLabel.font = [UIFont systemFontOfSize:17];
    
    [contactsChecked insertObject:@"FALSE" atIndex:indexPath.row];
    UIImage *image = [UIImage imageNamed:@"unchecked.png"];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    button.frame = frame;
    button.tag = indexPath.row;
    [button setBackgroundImage:image forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(checkButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView = button;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    BOOL checked = [[contactsChecked objectAtIndex:indexPath.row] boolValue];
    [contactsChecked removeObjectAtIndex:indexPath.row];
    [contactsChecked insertObject:checked?@"FALSE":@"TRUE" atIndex:indexPath.row];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIButton *button = (UIButton *)cell.accessoryView;
    
    UIImage *newImage = (checked)? [UIImage imageNamed:@"unchecked.png"]:[UIImage imageNamed:@"checked.png"];
    [button setBackgroundImage:newImage forState:UIControlStateNormal];
    
}

-(void)checkButtonTapped:(id)sender event:(UIEvent *)event{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.ContactList];
    NSIndexPath *indexPath = [self.ContactList indexPathForRowAtPoint:currentTouchPosition];
    if (indexPath!=nil) {
        [self tableView:self.ContactList accessoryButtonTappedForRowWithIndexPath:indexPath];
    }
}


@end

//
//  ChatsViewController.m
//  Chat
//
//  Created by Bo Wang on 6/23/13.
//  Copyright (c) 2013 Bo Wang. All rights reserved.
//

#import "ChatsViewController.h"
#import "FieldStudyAppDelegate.h"
#import "ChatDetailViewController.h"
#import "BubbleChatDetailViewController.h"
#define DEVICE_SCHOOL
//#define DEVICE_HOME
//#define SWITCHVIEW

@interface ChatsViewController () {
    
    NSURLConnection *conn;
    NSURLConnection *conn1;

    NSString *user;
    NSString *password;
    NSMutableData *receivedData;
    NSXMLParser *parser1,*parser2;   //parser1 for login, parser2 for group list
    
    Boolean inSuccess;
    Boolean inUser;
    NSString *userName;
    NSString *success;
    
    NSString *groupId;
    Boolean inGroupId;
    
    Boolean firstTime;
    
    NSMutableArray *groups;
}

@end

@implementation ChatsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    firstTime = YES;
    [self getGrouplist];
}

-(void)viewDidAppear:(BOOL)animated{
    [self getGrouplist];
    FieldStudyAppDelegate *delegate = (FieldStudyAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *log = [NSString stringWithFormat:@"%@ Entering ChatsView\n",[DateFormatter stringFromDate:[NSDate date]]];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:delegate.documentTXTPath];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:[log dataUsingEncoding:NSUTF8StringEncoding]];
    
    //test switch view use
#ifdef SWITCHVIEW
//    [NSTimer scheduledTimerWithTimeInterval:5.0f
//                                     target:self
//                                   selector: @selector(switchView)
//                                   userInfo:nil
//                                    repeats:NO];
    [self switchView];
#endif
}

-(void)switchView{
    [self.tabBarController setSelectedIndex:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"Groups count: %d",[groups count]);
    return (groups == nil)?0:[groups count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:
(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"chats";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    // Configure the cell...

    
    NSDictionary *itemAtIndex = (NSDictionary *)[groups objectAtIndex:indexPath.row];
    if ([[itemAtIndex objectForKey:@"groupId"] isEqualToString:@"0"]) {
        cell.textLabel.text = @"Broadcast";
    } else {
        cell.textLabel.text = [NSString stringWithFormat: @"Group(%@)",[itemAtIndex objectForKey:@"groupId"]];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:17];
    //cell.detailTextLabel.numberOfLines = 0;
    //cell.detailTextLabel.text = [itemAtIndex objectForKey:@"members"];
    //cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    ChatDetailViewController *detailViewController = [[ChatDetailViewController alloc] initWithNibName:nil bundle:nil];
//    NSDictionary *itemAtIndex = (NSDictionary *)[groups objectAtIndex:indexPath.row];
//    detailViewController.groupId = [itemAtIndex objectForKey:@"groupId"];
//    //NSLog(@"Group id is: %@",detailViewController.groupId);
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if ([segue.identifier isEqualToString:@"bubbleMessageSegue"]) {
        self.controller = segue.destinationViewController;
        NSDictionary *itemAtIndex = (NSDictionary *)[groups objectAtIndex:indexPath.row];
        self.controller.groupId = [itemAtIndex objectForKey:@"groupId"];
        self.controller.hidesBottomBarWhenPushed = YES;
    } 
}

- (void)getGrouplist{
    FieldStudyAppDelegate *delegate = (FieldStudyAppDelegate *)[[UIApplication sharedApplication] delegate];
#ifdef SIMULATOR
    NSString *url = [NSString stringWithFormat:
                     @"http://localhost:8888/ResearchProject/server-side/group-list.php?user=%@",delegate.userName];
#endif
    
#ifdef DEVICE_SCHOOL
    NSString *url = [NSString stringWithFormat:
                     @"http://69.166.62.3/~bowang/gsoc/group-list.php?user=%@",delegate.userName];
#endif
    
#ifdef DEVICE_HOME
    NSString *url = [NSString stringWithFormat:
                     @"http://192.168.0.72:8888/ResearchProject/server-side/group-list.php?user=%@",delegate.userName];
#endif
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    
    conn1=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (conn1)
    {
        NSLog(@"chat group connected");
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
    if (connection == conn1) {
        if ( groups == nil )
            groups = [[NSMutableArray alloc] init];
        
        [groups removeAllObjects];
        parser2 = [[NSXMLParser alloc] initWithData:receivedData];
        [parser2 setDelegate:self];
        [parser2 parse];
        [self.tableView reloadData];
    }

}

- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict {
    if (parser == parser2) {
        if ([elementName isEqualToString:@"group"]) {
            groupId =@"";
        }
        if ([elementName isEqualToString:@"groupId"]) {
            inGroupId = YES;
        }
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (parser == parser2) {
        if ( inGroupId ) {
            groupId = [string stringByTrimmingCharactersInSet:
                       [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if (parser == parser2) {
        if ( [elementName isEqualToString:@"group"] ) {
            [groups addObject:[NSDictionary dictionaryWithObjectsAndKeys:groupId,
                                 @"groupId",nil]];
        }
        
        if ( [elementName isEqualToString:@"groupId"] ) {
            inGroupId = NO;
        }
    }
}


@end

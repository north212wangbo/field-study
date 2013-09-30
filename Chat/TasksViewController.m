//
//  TasksViewController.m
//  FieldStdy
//
//  Created by Bo Wang on 7/10/13.
//  Copyright (c) 2013 Bo Wang. All rights reserved.
//

#import "TasksViewController.h"
#import "FieldStudyAppDelegate.h"
#import "TaskDetailViewController.h"
#define DEVICE_SCHOOL
//#define DEVICE_HOME

@interface TasksViewController () {
    NSMutableArray *tasks;
    NSMutableArray *tasksFinished;
    NSTimer *timer;
        
    NSString *user;
    NSMutableData *receivedData;
    NSXMLParser *parser;
    NSURLConnection *conn1,*conn2;
    
    Boolean inName;
    Boolean inAmount;
    Boolean inDesc;
    Boolean inCompleted;
    Boolean inTstamp;
    Boolean inSampleUpdate;
    NSString *sampleName;
    NSString *amount;
    NSString *desc;
    NSString *sampleId;
    NSString *completed;
    NSString *tstamp;
    NSString *tstampSample;
    NSDictionary *taskInfo;
    
    NSString *refreshDateString;
    NSString *refreshSampleDateString;
    
    Boolean getTaskManually;
}

@end

@implementation TasksViewController

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
    tasksFinished = [[NSMutableArray alloc] init];

     self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(getTaskListManually) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    refreshDateString = @"1970-01-01 00:00:00";
    refreshSampleDateString = @"1970-01-01 00:00:00";

    [self getTaskList];
}

-(void)viewDidAppear:(BOOL)animated{
    //[self getTaskList];
     FieldStudyAppDelegate *delegate = (FieldStudyAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *log = [NSString stringWithFormat:@"%@ Entering TaskView\n",[DateFormatter stringFromDate:[NSDate date]]];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:delegate.documentTXTPath];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:[log dataUsingEncoding:NSUTF8StringEncoding]];
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
    for (int i=0; i<[tasks count]; i++) {
        [tasksFinished addObject:@"FALSE"];
    }
    return (tasks == nil)? 0:[tasks count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:
(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"taskIdentifier"];
    //cell = (UITableViewCell *)[self.messageList dequeueReusableCellWithIdentifier:@"ChatListItem"];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"taskIdentifier"
                                                     owner:self options:nil];
        cell = (UITableViewCell *)[nib objectAtIndex:0];
    }
    
    NSDictionary *itemAtIndex = (NSDictionary *)[tasks objectAtIndex:indexPath.row];
    cell.textLabel.text = [itemAtIndex objectForKey:@"name"];
    cell.textLabel.font = [UIFont systemFontOfSize:17];
    cell.detailTextLabel.numberOfLines = 0;
    cell.detailTextLabel.text = [itemAtIndex objectForKey:@"desc"];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
    
    BOOL checked = [[tasksFinished objectAtIndex:indexPath.row] boolValue];
    UIImage *image = (checked)? [UIImage imageNamed:@"checked.png"]:[UIImage imageNamed:@"unchecked.png"];
    
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
    BOOL checked = [[tasksFinished objectAtIndex:indexPath.row] boolValue];
    [tasksFinished removeObjectAtIndex:indexPath.row];
    [tasksFinished insertObject:checked?@"FALSE":@"TRUE" atIndex:indexPath.row];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIButton *button = (UIButton *)cell.accessoryView;
    
    UIImage *newImage = (checked)? [UIImage imageNamed:@"unchecked.png"]:[UIImage imageNamed:@"checked.png"];
    [button setBackgroundImage:newImage forState:UIControlStateNormal];
    
}

-(void)checkButtonTapped:(id)sender event:(UIEvent *)event{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:currentTouchPosition];
    if (indexPath!=nil) {
        [self tableView:self.tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
    }
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

#pragma mark - Table view delegate and segue

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    
     //TaskDetailViewController *detailViewController = [[TaskDetailViewController alloc] init];
     // ...
     // Pass the selected object to the new view controller.
     //[self.navigationController pushViewController:detailViewController animated:YES];
    [self performSegueWithIdentifier:@"TaskDetailViewSegue" sender:self];
     
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if ([segue.identifier isEqualToString:@"TaskDetailViewSegue"]) {
        TaskDetailViewController *controller = segue.destinationViewController;
        NSDictionary *itemAtIndex = (NSDictionary *)[tasks objectAtIndex:indexPath.row];
        controller.taskId = [itemAtIndex objectForKey:@"id"];
        controller.hidesBottomBarWhenPushed = YES;
    }
}

#pragma mark - get task list

-(void)getTaskListManually  {
    getTaskManually = YES;
    [self getTaskList];
}

-(void)getTaskList{
    FieldStudyAppDelegate *delegate = (FieldStudyAppDelegate *)[[UIApplication sharedApplication] delegate];
    user = delegate.userName;
    
#ifdef DEVICE_SCHOOL
    NSString *url = [NSString stringWithFormat:@"http://69.166.62.3/~bowang/gsoc/get-student-tasks.php?user=%@",user];
    
#endif
    
#ifdef DEVICE_HOME
    NSString *url = [NSString stringWithFormat:@"http://192.168.0.72:8888/ResearchProject/server-side/get-student-tasks.php?user=%@",user];
#endif
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    
    conn1=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (conn1)
    {
        NSLog(@"get tasklist connected");
        receivedData = [[NSMutableData alloc] init];
    }
    else
    {
        NSLog(@"not connected");
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (connection == conn1) {
        if ( tasks == nil )
            tasks = [[NSMutableArray alloc] init];
        
        [tasks removeAllObjects];  //remove the record of previous user, so that records don't get repeated; should find better way
        parser = [[NSXMLParser alloc] initWithData:receivedData];
        [parser setDelegate:self];
        [parser parse];
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"..."]];
        
        NSDate *refreshDate = [dateFormatter dateFromString:refreshDateString];
        NSDate *refreshSampleDate = [dateFormatter dateFromString:refreshSampleDateString];
        for (id task in tasks) {
            NSString *timeStamp = [task objectForKey:@"tstamp"];
            NSDate *nextRefreshDate = [dateFormatter dateFromString:timeStamp];
            
            NSString *sampleTimeStamp = [task objectForKey:@"sampleUpdated"];
            NSDate *nextRefreshSampleDate = [dateFormatter dateFromString:sampleTimeStamp];
            
            if ([nextRefreshDate compare:refreshDate] == NSOrderedDescending) {
                refreshDate = nextRefreshDate;
            }
            
            if ([nextRefreshSampleDate compare:refreshSampleDate] == NSOrderedDescending) {
                refreshSampleDate = nextRefreshSampleDate;
            }
        }
        NSString *newRefreshDateString = [dateFormatter stringFromDate:refreshDate];
        NSString *newRefreshSampleDateString = [dateFormatter stringFromDate:refreshSampleDate];
        
        if (![newRefreshDateString isEqualToString:refreshDateString] || ![newRefreshSampleDateString isEqualToString:refreshSampleDateString] ) {
            refreshDateString = newRefreshDateString;
            refreshSampleDateString = newRefreshSampleDateString;
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:user,@"user",nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"taskUpdate" object:self userInfo:dict];
        }
        
        if (!getTaskManually) {
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                        [self methodSignatureForSelector: @selector(timerCallback)]];
            [invocation setTarget:self];
            [invocation setSelector:@selector(timerCallback)];
            timer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                 invocation:invocation repeats:NO];
        }
        getTaskManually = NO;
        
        FieldStudyAppDelegate *delegate = (FieldStudyAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
        [DateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        NSString *log = [NSString stringWithFormat:@"%@ Task refreshed!\n",[DateFormatter stringFromDate:[NSDate date]]];
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:delegate.documentTXTPath];
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[log dataUsingEncoding:NSUTF8StringEncoding]];
        
    } else if (connection == conn2) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        self.submitButton.enabled = YES;
        
        FieldStudyAppDelegate *delegate = (FieldStudyAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
        [DateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        NSString *log = [NSString stringWithFormat:@"%@ User submitted a task\n",[DateFormatter stringFromDate:[NSDate date]]];
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:delegate.documentTXTPath];
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[log dataUsingEncoding:NSUTF8StringEncoding]];
    }
}

- (void)timerCallback {
    [self getTaskList];
}

- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"sample"]) {
        sampleId = [attributeDict objectForKey:@"id"];
        inName = NO;
        inAmount = NO;
        inDesc =NO;
        inTstamp = NO;
        inSampleUpdate = NO;
    }
    if ([elementName isEqualToString:@"name"]) {
        inName = YES;
    }
    if ([elementName isEqualToString:@"amount"]) {
        inAmount = YES;
    }
    if ([elementName isEqualToString:@"desc"]) {
        inDesc = YES;
    }
    if ([elementName isEqualToString:@"completed"]) {
        inCompleted = YES;
    }
    if ([elementName isEqualToString:@"tstamp"]) {
        inTstamp = YES;
    }
    if ([elementName isEqualToString:@"sampleUpdated"]) {
        inSampleUpdate = YES;
    }
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if ( inName ) {
        sampleName = string;
    }
    if ( inAmount ) {
        amount = string;
    }
    if ( inDesc ) {
        desc = string;
    }
    if ( inCompleted ) {
        completed = string;
    }
    if ( inTstamp ) {
        tstamp = string;
    }
    if ( inSampleUpdate ) {
        tstampSample = string;
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ( [elementName isEqualToString:@"sample"] ) {
        taskInfo = [NSDictionary dictionaryWithObjectsAndKeys:sampleName, @"name",amount,@"amount",desc,@"desc",sampleId,@"id",completed,@"completed",tstamp,@"tstamp",tstampSample,@"sampleUpdated", nil];
        [tasks addObject:taskInfo];
        [tasksFinished addObject:@"FALSE"];
    }
    
    if ( [elementName isEqualToString:@"name"] ) {
        inName = NO;
    }
    if ( [elementName isEqualToString:@"amount"] ) {
        inAmount = NO;
    }
    if ( [elementName isEqualToString:@"desc"] ) {
        inDesc = NO;
    }
    if ( [elementName isEqualToString:@"completed"] ) {
        inCompleted = NO;
    }
    if ( [elementName isEqualToString:@"tstamp"] ) {
        inTstamp = NO;
    }
    if ( [elementName isEqualToString:@"sampleUpdated"] ) {
        inSampleUpdate = NO;
    }
}

- (IBAction)submit:(id)sender {
    self.submitButton.enabled = NO;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    for (int i=0; i<[tasks count];i++) {
        if ([[tasksFinished objectAtIndex:i] boolValue]==YES) {
            NSDictionary *itemAtIndex = [tasks objectAtIndex:i];
            NSString *saID = [itemAtIndex objectForKey:@"id"];
#ifdef DEVICE_SCHOOL
            NSString *url = [NSString stringWithFormat:@"http://69.166.62.3/~bowang/gsoc/update-task-status.php?user=%@&sample=%@&finish=YES",user,saID];
#endif
            
#ifdef DEVICE_HOME
            NSString *url =[NSString stringWithFormat:@"http://192.168.0.72:8888/ResearchProject/server-side/update-task-status.php?user=%@&sample=%@&finish=YES",user,saID];
#endif
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:[NSURL URLWithString:url]];
            [request setHTTPMethod:@"GET"];
            
            
            conn2 =[[NSURLConnection alloc] initWithRequest:request delegate:self];
            if (conn2)
            {
                NSLog(@"connected");
                receivedData = [[NSMutableData alloc] init];
            }
            else
            {
                NSLog(@"not connected");
            }
        } else {
            NSDictionary *itemAtIndex = [tasks objectAtIndex:i];
            NSString *saID = [NSString stringWithFormat:@"%@",[itemAtIndex objectForKey:@"id"]];
#ifdef DEVICE_SCHOOL
            NSString *url = [NSString stringWithFormat:@"http://69.166.62.3/~bowang/gsoc/update-task-status.php?user=%@&sample=%@&finish=NO",user,saID];
#endif
            
#ifdef DEVICE_HOME
            NSString *url = [NSString stringWithFormat:@"http://192.168.0.72:8888/ResearchProject/server-side/update-task-status.php?user=%@&sample=%@&finish=NO",user,saID];
#endif
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:[NSURL URLWithString:url]];
            [request setHTTPMethod:@"GET"];
            
            
            conn2 =[[NSURLConnection alloc] initWithRequest:request delegate:self];
            if (conn2)
            {
                NSLog(@"connected");
                receivedData = [[NSMutableData alloc] init];
            }
            else
            {
                NSLog(@"not connected");
            }
        }
    }
}



@end

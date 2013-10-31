//
//  MapViewController.m
//  Chat
//
//  Created by Bo Wang on 7/5/13.
//  Copyright (c) 2013 Bo Wang. All rights reserved.
//

#import "MapViewController.h"
#import "MyLocation.h"
#import <CoreLocation/CoreLocation.h>
#import "FieldStudyAppDelegate.h"
#import "MapAnnotationView.h"
#import "NotiView.h"
#import "NSTimer+Blocks.h"
#define METERS_PER_MILE 1609.344
#define DEVICE_SCHOOL
//#define DEVICE_HOME
#define TEST
//#define SWITCHVIEW
//#define TESTTIME
//#define SWITCHVIEWTIME

#include <mach/mach.h>
#include <mach/mach_time.h>
#include <unistd.h>

@interface MapViewController () {
    CLLocationManager *locationManager;
    NSMutableData *receivedData;
    NSMutableArray *locations;
    NSMutableArray *annotations;
    NSXMLParser *locationParser;
    
    NSString *name;
    NSString *latitude;
    NSString *longitude;
    Boolean inLatitude;
    Boolean inLongitude;
    
    NSTimer *timer;
    
    UIButton *refreshButton;
    Boolean refreshButtonTapped;

    double        start;
    double        end;
    double        elapsed;
}

@end

@implementation MapViewController

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receive:) name:@"messageUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receive:) name:@"taskUpdate" object:nil];
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,0,320,44)];
    self.searchBar.showsCancelButton = YES;
    [self.FieldMapView addSubview:self.searchBar];
    annotations = [[NSMutableArray alloc] init];
    self.navigationController.navigationBarHidden = YES;
    
    if (nil == locationManager)
        locationManager = [[CLLocationManager alloc] init];
    
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    self.FieldMapView.delegate = self;
    self.searchBar.delegate = self;
    
    // Set a movement threshold for new events.
    locationManager.distanceFilter = 500;
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.FieldMapView.userLocation.coordinate, 1*METERS_PER_MILE, 1*METERS_PER_MILE);
    
    [self.FieldMapView setRegion:viewRegion animated:YES];
    
    refreshButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [refreshButton addTarget:self action:@selector(refresh) forControlEvents:UIControlEventTouchDown];
    [refreshButton setImage:[UIImage imageNamed:@"navigator.png"] forState:UIControlStateNormal];
    //refreshButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    [self.FieldMapView addSubview:refreshButton];

#ifndef TEST
    [self getLocations];
#endif
}

-(void)viewDidAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
     FieldStudyAppDelegate *delegate = (FieldStudyAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *log = [NSString stringWithFormat:@"%@ Entering MapView\n",[DateFormatter stringFromDate:[NSDate date]]];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:delegate.documentTXTPath];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:[log dataUsingEncoding:NSUTF8StringEncoding]];

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
    FieldStudyAppDelegate *delegate = (FieldStudyAppDelegate *)[[UIApplication sharedApplication] delegate];
#ifdef  SWITCHVIEWTIME
    start = CACurrentMediaTime();
#endif
    
    [self.tabBarController setSelectedIndex:1];
    

#ifdef SWITCHVIEWTIME
    NSString *log;
    NSFileHandle *fileHandle;
    end = CACurrentMediaTime();
    elapsed = end - start;
    NSLog(@"%f",elapsed);
    log = [NSString stringWithFormat:@"locations updated: %f\n", elapsed];
    fileHandle = [NSFileHandle fileHandleForWritingAtPath:delegate.documentTXTPathTime];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:[log dataUsingEncoding:NSUTF8StringEncoding]];
#endif
}

-(void)viewWillLayoutSubviews {
    const CGRect viewBounds = self.view.bounds;
    const bool isPortrait = viewBounds.size.height >= viewBounds.size.width;
    if (isPortrait) {
        refreshButton.frame = CGRectMake(self.FieldMapView.bounds.size.width-45, self.FieldMapView.bounds.size.height-45, 40,40);
    } else {
        refreshButton.frame = CGRectMake(10, self.FieldMapView.bounds.size.width-45, 40,40);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat) viewWidth {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGFloat width = self.view.frame.size.width;
    if (orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft) {
        width = self.view.frame.size.height;
    }
    return width;
}

-(void)refresh{
    refreshButtonTapped = YES;
    FieldStudyAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    if (delegate.userName != nil){
        
        [self updateUserLocation];
        [self getLocations];
    }
}

-(void)updateUserLocation{
    FieldStudyAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    if (delegate.userName != nil){
#ifdef SIMULATOR
    NSString *url = [NSString stringWithFormat:@"http://localhost:8888/ResearchProject/server-side/update-user-location.php?user=%@&latitude=%f&longitude=%f", delegate.userName, self.FieldMapView.u serLocation.coordinate.latitude, self.FieldMapView.userLocation.coordinate.longitude];
#endif
    
#ifdef DEVICE_SCHOOL
    NSString *url = [NSString stringWithFormat:@"http://69.166.62.3/~bowang/gsoc/update-user-location.php?user=%@&latitude=%f&longitude=%f", delegate.userName, self.FieldMapView.userLocation.coordinate.latitude, self.FieldMapView.userLocation.coordinate.longitude];
#endif
    
#ifdef DEVICE_HOME
        NSString *url = [NSString stringWithFormat:@"http://192.168.0.72:8888/ResearchProject/server-side/update-user-location.php?user=%@&latitude=%f&longitude=%f", delegate.userName, self.FieldMapView.userLocation.coordinate.latitude, self.FieldMapView.userLocation.coordinate.longitude];
#endif
        
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                        init];
        [request setURL:[NSURL URLWithString:url]];
        [request setHTTPMethod:@"POST"];
        NSHTTPURLResponse *response = nil;
        NSError *error = [[NSError alloc] init];
        [NSURLConnection sendSynchronousRequest:request
                              returningResponse:&response error:&error];
    }
}

-(void)getLocations{
#ifdef  TESTTIME
    start = CACurrentMediaTime();
#endif
    
    FieldStudyAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
#ifdef SIMULATOR
        NSString *url = [NSString stringWithFormat:@"http://localhost:8888/ResearchProject/server-side/get-group-location.php?user=%@",delegate.userName];
#endif
        
#ifdef DEVICE_SCHOOL
        NSString *url = [NSString stringWithFormat:@"http://69.166.62.3/~bowang/gsoc/get-group-location.php?user=%@",delegate.userName];
#endif
        
#ifdef DEVICE_HOME
        NSString *url = [NSString stringWithFormat:@"http://192.168.0.72:8888/ResearchProject/server-side/get-group-location.php?user=%@",delegate.userName];
#endif
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:url]];
        [request setHTTPMethod:@"GET"];
        
        NSURLConnection *conn=[[NSURLConnection alloc] initWithRequest:request delegate:self];
        if (conn)
        {
            NSLog(@"location data connected");
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
    FieldStudyAppDelegate *delegate = (FieldStudyAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (delegate.userName != nil) {
        if ( locations == nil )
            locations = [[NSMutableArray alloc] init];
        
        [locations removeAllObjects];
        //    [annotations removeAllObjects];
        
        locationParser = [[NSXMLParser alloc] initWithData:receivedData];
        [locationParser setDelegate:self];
        [locationParser parse];
        
        //To do: change annotation style
        //Remove all the previous annotations except for the user location annotation
        
        //    while ([self.FieldMapView.annotations count] > 1) {
        //        [self.FieldMapView removeAnnotation:[self.FieldMapView.annotations lastObject]];
        //    }
        //
        NSLog(@"annotation count: %d",[self.FieldMapView.annotations count]);
        NSLog(@"annotation count #: %d",[annotations count]);
        
        if (refreshButtonTapped) { //If refresh button is tapped, zoom to user location
            MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.FieldMapView.userLocation.coordinate, 1*METERS_PER_MILE, 1*METERS_PER_MILE);
            [self.FieldMapView setRegion:viewRegion animated:YES];
        }
        
        for (id item in locations) {
            Boolean newAnnotation = YES;
            CLLocationCoordinate2D currLocation;
            currLocation.latitude = [[item objectForKey:@"latitude"] doubleValue];
            currLocation.longitude = [[item objectForKey:@"longitude"] doubleValue];
            NSString *currName = [item objectForKey:@"name"];
            
            for (MyLocation *annotation in self.FieldMapView.annotations) {
                if ([annotation.title isEqualToString:currName]) {
                    [annotation setCoordinate:currLocation];
                    newAnnotation = NO;
                    continue;
                }
            }
            if (newAnnotation) {
                MyLocation *annotation = [[MyLocation alloc] initWithName:currName coordinate:currLocation];
                [self.FieldMapView addAnnotation:annotation];
                [annotations addObject:annotation];            
            }
            
        }
    }
    
    NSString *log;
    NSFileHandle *fileHandle;
#ifdef TESTTIME
    end = CACurrentMediaTime();
    elapsed = end - start;
    NSLog(@"%f",elapsed);
    log = [NSString stringWithFormat:@"locations updated: %f\n", elapsed];
    fileHandle = [NSFileHandle fileHandleForWritingAtPath:delegate.documentTXTPathTime];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:[log dataUsingEncoding:NSUTF8StringEncoding]];
#endif
    
    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    log = [NSString stringWithFormat:@"%@ locations updated\n",[DateFormatter stringFromDate:[NSDate date]]];
    fileHandle = [NSFileHandle fileHandleForWritingAtPath:delegate.documentTXTPath];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:[log dataUsingEncoding:NSUTF8StringEncoding]];
        
#ifdef TEST
    /*test mode, refresh every 5 seconds if refresh button tapped*/
//    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
//                                [self methodSignatureForSelector: @selector(timerCallback)]];
//    [invocation setTarget:self];
//    [invocation setSelector:@selector(timerCallback)];
//    timer = [NSTimer scheduledTimerWithTimeInterval:5.0
//                                         invocation:invocation repeats:NO];
    [self updateUserLocation];
    [self getLocations];
#else
    if (refreshButtonTapped == NO) {//if location updates caused by refresh button, does not call |timerCallback|
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                    [self methodSignatureForSelector: @selector(timerCallback)]];
        [invocation setTarget:self];
        [invocation setSelector:@selector(timerCallback)];
        timer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                             invocation:invocation repeats:NO];
    } else {
        refreshButtonTapped = NO;
    }
#endif

    
}

- (void)timerCallback {
    [self updateUserLocation];
    [self getLocations];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict {
    if ( [elementName isEqualToString:@"user"] ) {
        name = [attributeDict objectForKey:@"name"];
        latitude = @"";
        longitude = @"";
        inLatitude = NO;
        inLongitude = NO;
    }
    if ( [elementName isEqualToString:@"latitude"] ) {
        inLatitude = YES;
    }
    if ( [elementName isEqualToString:@"longitude"] ) {
        inLongitude = YES;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if ( inLatitude ) {
        latitude = string;
    }
    if ( inLongitude ) {
        longitude = string;
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ( [elementName isEqualToString:@"user"] ) {
        [locations addObject:[NSDictionary dictionaryWithObjectsAndKeys:name,
                             @"name",latitude,@"latitude",longitude,@"longitude",nil]];
    }
    if ( [elementName isEqualToString:@"latitude"] ) {
        inLatitude = NO;
    }
    if ( [elementName isEqualToString:@"longitude"] ) {
        inLongitude = NO;
    }
}

#pragma mark MKMapViewDelegate

- (MKAnnotationView *)mapView: (MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    NSLog(@"gets called");
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    static NSString *kAnnotationViewId = @"MapAnnotationView";
    
    MapAnnotationView *annotationView = (MapAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:kAnnotationViewId];
    if (!annotationView) {
        annotationView = [[MapAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kAnnotationViewId];
    }
    
    annotationView.image = [UIImage imageNamed:@"symbol-moving-annotation.png"];
    annotationView.bounds = CGRectMake(0,0,20,20);
    
    return annotationView;
}

#pragma mark - push chatview

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    NSLog(@"accessory button tapped for annotation %@", view.annotation);
    [self performSegueWithIdentifier:@"MapToChatSegue" sender:self];
}

- (void)openAnnotation:(id)annotation
{
    [self.FieldMapView selectAnnotation:annotation animated:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"MapToChatSegue"]) {
        BubbleChatDetailViewController *controller = segue.destinationViewController;
        controller.groupId = @"0";   //broadcast channel
        controller.hidesBottomBarWhenPushed = YES;
    }
}

#pragma mark - recieve messages and open relative annotation

-(void)receive: (NSNotification *)note
{
    if ([[note name] isEqualToString:@"messageUpdate"] ) {
        NSDictionary *dataDict = [note userInfo];
        NSString *text = [dataDict objectForKey:@"text"];
        NSString *messageSender = [dataDict objectForKey:@"user"];
        
        for (MyLocation *annotation in annotations) {
            if ([annotation.title isEqualToString:messageSender]) {
                [self openAnnotation:annotation];
            }
        }
        
        NotiView *nv = [[NotiView alloc] initWithTitle:messageSender detail:text icon:nil];
        
        CGRect f = nv.frame;
        f.origin.x = [self viewWidth] - f.size.width - 20;
        f.origin.y = -f.size.height;
        nv.frame = f;
        [self.view addSubview:nv];
        
        [UIView animateWithDuration:0.4 animations:^{
            nv.frame = CGRectOffset(nv.frame, 0.0, f.size.height+20.0);
        } completion:^(BOOL finished) {
            [NSTimer scheduledTimerWithTimeInterval:4.0 repeats:NO block:^(NSTimer *timer) {
                [UIView animateWithDuration:0.4 animations:^{
                    nv.frame = CGRectOffset(nv.frame, f.size.width+20, 0.0);
                } completion:^(BOOL finished) {
                    [nv removeFromSuperview];
                }];
            }];
        }];
    } else if ([[note name] isEqualToString:@"taskUpdate"]) {
        NSDictionary *dataDict = [note userInfo];
        NSString *user = [dataDict objectForKey:@"user"];
        NSString *detail = @"You have task updates";
        NotiView *nv = [[NotiView alloc] initWithTitle:user detail:detail icon:nil];
        
        CGRect f = nv.frame;
        f.origin.x = [self viewWidth] - f.size.width - 20;
        f.origin.y = -f.size.height;
        nv.frame = f;
        [self.view addSubview:nv];
        
        [UIView animateWithDuration:0.4 animations:^{
            nv.frame = CGRectOffset(nv.frame, 0.0, f.size.height+20.0);
        } completion:^(BOOL finished) {
            [NSTimer scheduledTimerWithTimeInterval:4.0 repeats:NO block:^(NSTimer *timer) {
                [UIView animateWithDuration:0.4 animations:^{
                    nv.frame = CGRectOffset(nv.frame, f.size.width+20, 0.0);
                } completion:^(BOOL finished) {
                    [nv removeFromSuperview];
                }];
            }];
        }];
    }

    
}

#pragma mark - search bar implementation

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    for (MyLocation *annotation in annotations) {
        if ([annotation.title isEqualToString:searchBar.text]) {
            [self.searchBar resignFirstResponder];
            MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1*METERS_PER_MILE, 1*METERS_PER_MILE);
            [self.FieldMapView setRegion:viewRegion animated:YES];
            [self openAnnotation:annotation];
        }
    }
    [self.searchBar resignFirstResponder];
}

@end

//
//  MapViewController.h
//  Chat
//
//  Created by Bo Wang on 7/5/13.
//  Copyright (c) 2013 Bo Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "BubbleChatDetailViewController.h"

@interface MapViewController : UIViewController <NSXMLParserDelegate,CLLocationManagerDelegate,MKMapViewDelegate,UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *FieldMapView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;



@end

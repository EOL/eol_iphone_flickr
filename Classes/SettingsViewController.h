//
//  SettingsViewController.h
//  cameraTest
//
//  Created by Charles Mezak on 12/11/08.
//  Natural Guides, LLC
//

#import <UIKit/UIKit.h>
#import "DataController.h"
#import "FlickrController.h"
#import "FlickrAuthViewController.h"

@interface SettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {

	UITableView *settingsTableView;
	UIToolbar	*toolbar;
	DataController *dataController;
	FlickrController *flickrController;
	
}

@property (nonatomic, retain)	UITableView *settingsTableView;
@property (nonatomic, retain)	UIToolbar *toolbar;
@property (nonatomic, retain)	DataController *dataController;
@property (nonatomic, retain)	FlickrController *flickrController;

- (void)deleteAll;
- (void)authorize;
- (void)aboutThisApp;

@end

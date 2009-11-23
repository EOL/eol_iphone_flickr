//
//  EOLAppDelegate.h
//  EOL
//
//  Created by Charlie Mezak on 11/18/09.
//  Copyright Natural Guides, LLC 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataController.h"
#import "FlickrAuthViewController.h"
#import "ImageBrowserViewController.h"

@interface EOLAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow			*window;
	DataController		*dataController;
	FlickrController	*flickrController;
	
}

@property (nonatomic, retain)	IBOutlet UIWindow		*window;
@property (nonatomic, retain)	DataController			*dataController;
@property (nonatomic, retain)	FlickrController		*flickrController;

- (void)copyPlistFiles;

@end



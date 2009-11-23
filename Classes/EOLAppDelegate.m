//
//  EOLAppDelegate.m
//  EOL
//
//  Created by Charlie Mezak on 11/18/09.
//  Copyright Natural Guides, LLC 2009. All rights reserved.
//

#import "EOLAppDelegate.h"

@implementation EOLAppDelegate
@synthesize window, dataController, flickrController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {  
	[self copyPlistFiles];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
	flickrController = [FlickrController sharedController];
	dataController = [DataController sharedController];
	ImageBrowserViewController *browserController = [[ImageBrowserViewController alloc] init];
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:browserController];
	[navController setNavigationBarHidden:YES];
	if (![flickrController token]) {
		FlickrAuthViewController *authViewController = [[FlickrAuthViewController alloc] init];
		[navController pushViewController:authViewController animated:NO];
	}
	[window setBackgroundColor:[UIColor blackColor]];
	[window addSubview:navController.view];
    // Override point for customization after application launch
    [window makeKeyAndVisible];
}

- (void)copyPlistFiles {
	// First, test for existence.
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *docPath = [documentsDirectory stringByAppendingPathComponent:@"/Images.plist"];
    success = [fileManager fileExistsAtPath:docPath];
	
    if (success) {
		NSLog(@"images plist file already exists in documents directory.");
	} else {
		[fileManager copyItemAtPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"/Images.plist"] toPath:docPath error:nil];
	}
	
	docPath = [documentsDirectory stringByAppendingPathComponent:@"/UserInfo.plist"];
    success = [fileManager fileExistsAtPath:docPath];
	
    if (success) {
		NSLog(@"userInfo plist file already exists in documents directory.");
	} else {
		[fileManager copyItemAtPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"/UserInfo.plist"] toPath:docPath error:nil];
	}
	
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[dataController saveData];
	[flickrController saveData];
}

- (void)dealloc {
    [window release];
    [super dealloc];
}


@end

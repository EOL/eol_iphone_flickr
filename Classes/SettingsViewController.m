//
//  SettingsViewController.m
//  cameraTest
//
//  Created by Charles Mezak on 12/11/08.
//  Natural Guides, LLC
//

#import "SettingsViewController.h"


@implementation SettingsViewController

@synthesize settingsTableView, toolbar, dataController, flickrController;

- (id)init {
	
	self = [super init];
	
	self.dataController = [DataController sharedController];
	self.flickrController = [FlickrController sharedController];
	
	settingsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.bounds.size.height) style:UITableViewStyleGrouped];
	[settingsTableView setDelegate:self];
	[settingsTableView setDataSource:self];
	
	[self.view addSubview:settingsTableView];
	
	toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 60, 320, 60)];
	[toolbar setBarStyle:UIBarStyleBlackTranslucent];
	
	UIBarButtonItem *browseButton =		[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"grid.png"]	style:UIBarButtonItemStyleBordered target:self action:@selector(backToBrowser)];
	UIBarButtonItem *eLogoButton =		[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"eBar.png"] style:UIBarButtonItemStylePlain target:self action:@selector(eLink)];
	UIBarButtonItem *flexibleSpace =	[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace					target:nil	action:nil];

	[toolbar setItems:[NSArray arrayWithObjects:browseButton, flexibleSpace, eLogoButton, nil]];
	
	[self.view addSubview:toolbar];
	
	[browseButton release];	
	[flexibleSpace release];
	[eLogoButton release];
	
	return self;
}

- (void)eLink {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.eol.org"]];	
}

- (void)backToBrowser {
	[self.navigationController popViewControllerAnimated:YES];	
}

- (void)deleteAll {
	[dataController deleteAllEOLImages];
}

- (void)deleteAllAlert {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete All Photos?" message:@"Do you want to delete all of the photos from this app?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Delete", nil];
	[alert setTag:0];
	[alert show];
	[alert release];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return 2;
			break;
		case 1:
			return 1;
			break;
		case 2:
			return 1;
			break;
		default:
			break;
	}
	return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case 0:
			switch (indexPath.row) {
				case 0:
					return 180;
					break;
				case 1:
					return 45;
					break;
				default:
					break;
			}
			break;
		case 1:
					return 45;

			break;
		case 2:
			switch (indexPath.row) {
				case 0:
					return 45;				
					break;
				case 1:
					return 45;
					break;
				case 2:
					return 60;
					break;
				default:
					break;
			}
		default:
			break;
	}
	return 5;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	switch (indexPath.section) {
		case 0:
			switch (indexPath.row) {
				case 0:
					cell.accessoryType = UITableViewCellAccessoryNone;
					cell.imageView.image = [UIImage imageNamed:@"settingsLogo.png"];
					break;
				case 1:
					cell.textLabel.text = @"About This App";
					break;
				default:
					break;
			}
			break;
		case 1:
			switch (indexPath.row) {
				case 0:
					cell.textLabel.text = @"Authenticate with Flickr";
					break;
				default:
					break;
			}
			break;
		case 2:
			switch (indexPath.row) {
				case 0:
					cell.accessoryType = UITableViewCellAccessoryNone;
					UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
					deleteButton.frame = CGRectMake(0.0, 0.0, 300, 45);
					[deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
					[deleteButton setTitle:@"Delete All Photos From App" forState:UIControlStateNormal];
					[deleteButton setBackgroundImage:[[UIImage imageNamed:@"redButton.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0] forState:UIControlStateNormal];
					deleteButton.userInteractionEnabled = NO;
					[cell.contentView addSubview:deleteButton];					
					break;
				case 1:
					cell.textLabel.text = @"Designed and Written by Natural Guides, LLC";
					break;
				case 2:
					cell.alpha = 0;
					cell.userInteractionEnabled = NO;
					break;
				default:
					break;
			}
			break;
		default:
			break;
	}
	
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case 0:
			switch (indexPath.row) {
				case 0:
					[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.eol.org/"]];
					break;
				case 1:
					[self aboutThisApp];
					break;
				default:
					break;
			}
			break;
		case 1:
			switch (indexPath.row) {
				case 0:
					[self authorize];
					break;
				default:
					break;
			}
			break;
		case 2:
			switch (indexPath.row) {
				case 0:
					[settingsTableView deselectRowAtIndexPath:[settingsTableView indexPathForSelectedRow] animated:YES];
					[self deleteAllAlert];
					break;
				case 1:
					[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.naturalguides.com"]];
					break;
				default:
					break;
			}
			break;
		default:
			break;
	}
}

- (void)authorize {
	FlickrAuthViewController *authController = [[[FlickrAuthViewController alloc] init] autorelease];
	[self.navigationController pushViewController:authController animated:YES];	
}

- (void)aboutThisApp {
	
	[settingsTableView deselectRowAtIndexPath:[settingsTableView indexPathForSelectedRow] animated:YES];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"About this app" message:@"Start contributing to the Encyclopedia Of Life by taking photos that automatically upload to the EOL Flickr Group.  For more information about EOL, tap the logo on this page to visit www.eol.org\n\nThis app was designed and written by Natural Guides, LLC www.naturalguides.com" delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:@"EOL Website", @"Natural Guides Website", nil];
	[alert setTag:1];
	
	[alert show];
	[alert release];
	
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	switch (alertView.tag) {
		case 0:
			if (buttonIndex == 1) [dataController deleteAllEOLImages];	
			break;
		case 1:
			switch (buttonIndex) {
				case 1:
					[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.eol.org"]];
					break;
				case 2:
					[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.naturalguides.com"]];
					break;
				default:
					break;
			}
			break;
		default:
			break;
	}
	
	
	
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[settingsTableView deselectRowAtIndexPath:[settingsTableView indexPathForSelectedRow] animated:YES];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[settingsTableView release];
	[toolbar release];
    [super dealloc];
}


@end

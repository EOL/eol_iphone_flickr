//
//  ImageDetailViewController.m
//  cameraTest
//
//  Created by Charles Mezak on 12/7/08.
//  Natural Guides, LLC
//

#import "ImageDetailViewController.h"


@implementation ImageDetailViewController

@synthesize imageView, thisEOLImage, dataController, flickrController, toolBar, imageIndex, spinner, spinnerBarButtonItem;
@synthesize browseButton, uploadButton, deleteButton, flexibleSpace, locationLabel, binomialField, commonField, dateLabel;
@synthesize goToFlickrButton;

- (id)initWithImageIndex:(int)anImageIndex {
    if (self = [super initWithNibName:nil bundle:nil]) {
		
		NSLog(@"iitializing detail view controller");
		
		self.imageIndex = anImageIndex;
		
		[self.view setBackgroundColor:[UIColor whiteColor]];
		
		self.flickrController = [FlickrController sharedController];
		self.dataController =	[DataController sharedController];
		
		thisEOLImage = [[dataController EOLImages] objectAtIndex:imageIndex];
		[thisEOLImage setDelegate:self];
		if (![thisEOLImage locationSet]) [thisEOLImage updateLocation];
		
		NSString *imageFileName = [thisEOLImage imageFileName];
		NSString *imagePath = [[dataController documentsDirectory] stringByAppendingPathComponent:imageFileName];
		
		UIImage *thisImage = [UIImage imageWithContentsOfFile:imagePath];
				
		if (thisImage.size.width > thisImage.size.height) {
			imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 160, 300, 225)];
			
		} else {
			imageView = [[UIImageView alloc] initWithFrame:CGRectMake(52, 160, 216, 225)];
			
		}
		
		[imageView setImage:thisImage];
		[imageView setContentMode:UIViewContentModeScaleAspectFit];
		
		[self.view addSubview:imageView];
		
		//
		// Toolbar setup
		//
		
		toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 60, 320, 60)];
		[toolBar setBarStyle:UIBarStyleBlackTranslucent];

		browseButton =		[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"grid.png"]			style:UIBarButtonItemStyleBordered	target:self action:@selector(backToBrowser)];
		uploadButton =		[[UIBarButtonItem alloc] initWithTitle:@"Send to Flickr"						style:UIBarButtonItemStyleDone		target:self action:@selector(uploadImage)];
		deleteButton =		[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash										target:self action:@selector(showDeleteAlert)];
		flexibleSpace =		[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace								target:nil	action:nil];
		goToFlickrButton =	[[UIBarButtonItem alloc] initWithTitle:@"View on Flickr"						style:UIBarButtonItemStyleBordered	target:self action:@selector(goToFlickr)];

		if (![thisEOLImage uploaded]) [toolBar setItems:[NSArray arrayWithObjects:browseButton, flexibleSpace, uploadButton, flexibleSpace, deleteButton, nil]];
		else [toolBar setItems:[NSArray arrayWithObjects:browseButton, flexibleSpace, goToFlickrButton, flexibleSpace, deleteButton, nil]];
			
		[self.view addSubview:toolBar];
		
		spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		[spinner setFrame:CGRectMake(0, 0, 25, 25)];
		spinnerBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
		
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
		[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
		
		dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 30)];
		[dateLabel setText:[dateFormatter stringFromDate:[thisEOLImage date]]];
		[dateLabel setTextAlignment:UITextAlignmentCenter];
		[self.view addSubview:dateLabel];
		
		[dateFormatter release];
		
		locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, 300, 30)];
		[locationLabel setTextAlignment:UITextAlignmentCenter];
		NSString *locationString = [NSString stringWithFormat:@"Latitude: %2.3f;  Longitude: %2.3f", [thisEOLImage latitude], [thisEOLImage longitude]];
		[locationLabel setText:locationString];
		[self.view addSubview:locationLabel];
		
		commonField = [[UITextField alloc] initWithFrame:CGRectMake(10, 80, 300, 30)];
		[commonField setBorderStyle:UITextBorderStyleRoundedRect];
		[commonField setPlaceholder:@"Common Name"];
		[commonField setText:[thisEOLImage common]];
		[commonField setClearButtonMode:UITextFieldViewModeAlways];
		[commonField setReturnKeyType:UIReturnKeyDone];
		[commonField setDelegate:self];
		[commonField setAutocorrectionType:UITextAutocorrectionTypeNo];
		[commonField setAutocapitalizationType:UITextAutocapitalizationTypeWords];
		[self.view addSubview:commonField];
		
		binomialField = [[UITextField alloc] initWithFrame:CGRectMake(10, 120, 300, 30)];
		[binomialField setBorderStyle:UITextBorderStyleRoundedRect];
		[binomialField setPlaceholder:@"Scientific Name"];
		[binomialField setText:[thisEOLImage binomial]];
		[binomialField setClearButtonMode:UITextFieldViewModeAlways];
		[binomialField setReturnKeyType:UIReturnKeyDone];
		[binomialField setDelegate:self];
		[binomialField setAutocorrectionType:UITextAutocorrectionTypeNo];
		[binomialField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		[self.view addSubview:binomialField];
		
		[self updateInfo];
		
		NSLog(@"initialized detail view controller");
		
    }
    return self;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	//send the new name to the EOL Image object
	if ([textField.placeholder isEqualToString:@"Common Name"]) {
		NSLog(@"common name edited");
		[thisEOLImage setCommon:textField.text];
	} else {
		NSLog(@"scientific name edited");
		[thisEOLImage setBinomial:textField.text];
	}
}

//click Search on UIKeyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	// Minimizes UIKeyboard on screen
	[textField resignFirstResponder];
		
	return YES;
}

- (void)updateInfo {
	NSString *locationString = [NSString stringWithFormat:@"Latitude: %2.3f;  Longitude: %2.3f", [thisEOLImage latitude], [thisEOLImage longitude]];
	[locationLabel setText:locationString];
	
}

- (void)goToFlickr {
	
	[[UIApplication sharedApplication] openURL:[thisEOLImage URLOfImageOnFlickr]];

}

- (void)goBack {
	
}

- (void)goForward {
	
}

- (void)imageDidUpdateLocation {
	[self updateInfo];
}

- (void)imageDidUploadToFlickr {
	[spinner stopAnimating];
	[toolBar setItems:[NSArray arrayWithObjects:browseButton, flexibleSpace, goToFlickrButton, flexibleSpace, deleteButton, nil]];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Your photo has been uploaded to the EOL Flickr Group. Thanks!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Flickr"];
	[alert setTag:1];
	[alert show];
	[alert release];
}

- (void)imageDidFailToUploadToFlickr {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"You don't seem to be connected to the internet.  Try this again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
	[toolBar setItems:[NSArray arrayWithObjects:browseButton, flexibleSpace, uploadButton, flexibleSpace, deleteButton, nil]];

}

- (void)uploadImage {
	
	//check to see that metadata exists
	if ([binomialField.text isEqualToString:@""] && [commonField.text isEqualToString:@""]) {
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"oops!" message:@"You must give this image either a scientific or common name before uploading." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	} else if (![flickrController token]){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"oops!" message:@"You are not yet autheticted with Flickr.  You can autheticate through the settings menu." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Authenticate", nil];
		[alert setTag:2];
		[alert show];
		[alert release];
		
	} else {
		[spinner startAnimating];
		[toolBar setItems:[NSArray arrayWithObjects:browseButton, flexibleSpace, spinnerBarButtonItem, flexibleSpace, deleteButton, nil]];
		[thisEOLImage upload];
	}
	
}

- (void)showDeleteAlert {
	if ([thisEOLImage uploaded]) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete Image?" message:@"Do you want to delete this image?"
														   delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete From Device", @"Delete From Flickr, Too", nil];
		[alertView setTag:0];
		[alertView show];	
		[alertView release];
	} else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete Image?" message:@"Do you want to delete this image?"
														   delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
		[alertView setTag:0];
		[alertView show];	
		[alertView release];
	}
}

- (void)deleteImage {
	[dataController deleteImage:imageIndex FromFlickr:NO];
	[self backToBrowser];
}

- (void)deleteImageFromFlickr {
	[dataController deleteImage:imageIndex FromFlickr:YES];
	[self backToBrowser];
}

- (void)backToBrowser {
	[self.navigationController popViewControllerAnimated:YES];
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
	[thisEOLImage setDelegate:nil];
	[imageView release];
	[toolBar release];
	[spinner release];
	[uploadButton release];
	[goToFlickrButton release];
	[binomialField release];
	[commonField release];
	[deleteButton release];
	[browseButton release];
	[flexibleSpace release];
	[spinnerBarButtonItem release];
	[locationLabel release];
	[dateLabel release];
    [super dealloc];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (alertView.tag) {
		case 0:
			if (buttonIndex == [alertView firstOtherButtonIndex]) [self deleteImage];
			else if (buttonIndex == [alertView firstOtherButtonIndex] + 1) [self deleteImageFromFlickr];
			break;
		case 1:
			if (buttonIndex == 1) [self goToFlickr];	
			break;
		case 2:
			if (buttonIndex == 1) {
				FlickrAuthViewController *authController = [[[FlickrAuthViewController alloc] init] autorelease];
				[self.navigationController pushViewController:authController animated:YES];
				
			}
		default:
			break;
	}
}


@end

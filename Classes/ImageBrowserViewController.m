//
//  ImageBrowserViewController.m
//  cameraTest
//
//  Created by Charles Mezak on 12/7/08.
//  Natural Guides, LLC
//

#import "ImageBrowserViewController.h"
#include <math.h>
static inline double radians (double degrees) {return degrees * M_PI/180;}

@implementation ImageBrowserViewController

@synthesize imageScrollView, dataController, flickrController, toolBar, imagePicker;


- (id)init {
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.dataController =	[DataController sharedController];
		self.flickrController = [FlickrController sharedController];
		
		[self.view setBackgroundColor:[UIColor whiteColor]];
		
		self.imageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
		self.toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, imageScrollView.bounds.size.height - 60, 320, 60)];
		
		[imageScrollView setBackgroundColor:[UIColor clearColor]];
		
		[toolBar setBarStyle:UIBarStyleBlackTranslucent];
		
		UIBarButtonItem *cameraButton =		[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(newImage)];
		UIBarButtonItem *setttingsButton =	[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showSettings)];	
		UIBarButtonItem *flexibleSpace =	[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		UIBarButtonItem *eLogoButton =		[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"eBar.png"] style:UIBarButtonItemStylePlain target:self action:@selector(eLink)];
		
		[toolBar setItems:[NSArray arrayWithObjects:flexibleSpace, cameraButton, flexibleSpace, setttingsButton, flexibleSpace, eLogoButton, flexibleSpace, nil]];
		
		[cameraButton release];
		[setttingsButton release];
		[flexibleSpace release];
		[eLogoButton release];

    }
    return self;
}

- (void)eLink {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.eol.org"]];	
}

- (void)imageButtonPressed:(id)sender {
	
	UIButton *tappedButton = (UIButton*)sender;
	
	int buttonIndex = ((tappedButton.frame.origin.x - 5) / 105) + (((tappedButton.frame.origin.y - 5) / 105) * 3);
	
	[self showDetailsForImage:buttonIndex];
}

- (void)showDetailsForImage:(int)imageIndex {
	
	ImageDetailViewController *detailViewController = [[[ImageDetailViewController alloc] initWithImageIndex:imageIndex] autorelease];
	
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)reloadSubviews {
	
	[self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	UIImageView *logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
	[logoView setFrame:CGRectMake(0, 0, 320, 460)];
	[self.view addSubview:logoView];
	[self.view addSubview:imageScrollView];
	[self.view addSubview:toolBar];
	
	[logoView release];
	
	[imageScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	 
	UIButton	*imageButton;
	EOLImage	*thisEOLImage;
	UIImage		*thisThumbnailImage;
	
	if ([dataController imageCount] > 0) {
	
	for (int i = 0; i < [dataController imageCount]; i++) {
		
		NSLog(@"adding image button");
		
		thisEOLImage = [[dataController EOLImages] objectAtIndex:i];
		
		NSString *thumbnailPath = [[dataController documentsDirectory] stringByAppendingPathComponent:[thisEOLImage thumbnailFileName]];
		
		thisThumbnailImage = [UIImage imageWithContentsOfFile:thumbnailPath];
		
		imageButton = [[UIButton alloc] initWithFrame:CGRectMake((i%3)*105 + 5, floor(i/3) * 105 + 5, 100, 100)];
		[imageButton setContentMode:UIViewContentModeScaleAspectFill];
		[imageButton setImage:thisThumbnailImage forState:UIControlStateNormal];
		[imageButton addTarget:self action:@selector(imageButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
		
		[imageScrollView addSubview:imageButton];
		
		[imageButton release];
	}	
	
	int numberOfRows = ceil([dataController imageCount]/3.0) + 1;
	NSLog([NSString stringWithFormat:@"aren't there %d rows?", numberOfRows]);
	
	[imageScrollView setContentSize:CGSizeMake(320, numberOfRows * 105 + 5)];
	
	} else {
		UITextView *instructionsView = [[UITextView alloc] initWithFrame:CGRectMake(30, 30, 260, self.view.bounds.size.height - 120)];
		[instructionsView setText:@"Start contributing to the Encyclopedia Of Life by taking photos that automatically upload to the EOL Flickr Group.  For more information about EOL, tap the logo on this page to visit www.eol.org"];
		[instructionsView setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.3]];
		[instructionsView setFont:[UIFont fontWithName:@"Helvetica" size:25]];
		[instructionsView setTextAlignment:UITextAlignmentCenter];
		[instructionsView setEditable:NO];
		[self.view addSubview:instructionsView];
		[instructionsView release];
	}
	
	NSLog(@"done setting up browser buttons");
	
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[self dismissModalViewControllerAnimated:YES];
	[picker release];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
	
	[self dismissModalViewControllerAnimated:YES];
	
	[dataController addEOLImageWithImage:image];
	
	[self showDetailsForImage:[dataController imageCount] - 1];
		
	[imagePicker release];

}

- (void)newImage {
	imagePicker = [[UIImagePickerController alloc] init];
	[imagePicker setDelegate:self];
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
	else [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
	[self presentModalViewController:imagePicker animated:YES];
}

- (void)showSettings {
	
	SettingsViewController *settingsController = [[[SettingsViewController alloc] init] autorelease];
	[self.navigationController pushViewController:settingsController animated:YES];
	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self reloadSubviews];
}


- (void)dealloc {
    [super dealloc];
}


@end

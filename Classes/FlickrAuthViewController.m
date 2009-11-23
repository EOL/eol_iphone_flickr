//
//  FlickrAuthViewController.m
//  cameraTest
//
//  Created by Charles Mezak on 12/3/08.
//  Natural Guides, LLC
//

#import "FlickrAuthViewController.h"


@implementation FlickrAuthViewController

@synthesize webView, toolBar, titleBar, flickrController, firstField, secondField, thirdField, spinner;

- (id)init {
	
	self = [super init];
	
	
	flickrController = [FlickrController sharedController];
	
	titleBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
	toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 40, self.view.bounds.size.width, 40)];
	webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 80, self.view.bounds.size.width, self.view.bounds.size.height - 80)];
	spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(145, 185, 30, 30)];

	[titleBar setBarStyle:UIBarStyleBlackOpaque];
	UIBarButtonItem *titleItem = [[UIBarButtonItem alloc] initWithTitle:@"Authenticate With Flickr" style:UIBarButtonItemStylePlain target:nil action:nil];
	UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[titleBar setItems:[NSArray arrayWithObjects:flexSpace, titleItem, flexSpace, nil]];

	
	[webView setScalesPageToFit:YES];
	[webView setDelegate:self];
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://m.flickr.com/auth-72157610626064051"]]];
	
	
	[toolBar setBarStyle:UIBarStyleBlackTranslucent];
	
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(done)];
	
	firstField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 40, 25)];
	[firstField setTextAlignment:UITextAlignmentCenter];
	[firstField setBackgroundColor:[UIColor whiteColor]];
	[firstField setKeyboardType:UIKeyboardTypeNumberPad];
	[firstField setTag:1];
	[firstField setDelegate:self];
	UIBarButtonItem *firstFieldItem = [[UIBarButtonItem alloc] initWithCustomView:firstField];
	
	secondField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 40, 25)];
	[secondField setTextAlignment:UITextAlignmentCenter];
	[secondField setBackgroundColor:[UIColor whiteColor]];
	[secondField setKeyboardType:UIKeyboardTypeNumberPad];
	[secondField setTag:2];
	[secondField setDelegate:self];
	UIBarButtonItem *secondFieldItem = [[UIBarButtonItem alloc] initWithCustomView:secondField];
	
	thirdField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 40, 25)];
	[thirdField setTextAlignment:UITextAlignmentCenter];
	[thirdField setBackgroundColor:[UIColor whiteColor]];
	[thirdField setKeyboardType:UIKeyboardTypeNumberPad];
	[thirdField setTag:3];
	[thirdField setDelegate:self];
	UIBarButtonItem *thirdFieldItem = [[UIBarButtonItem alloc] initWithCustomView:thirdField];
	
	
	[toolBar setItems:[NSArray arrayWithObjects:flexSpace, firstFieldItem, secondFieldItem, thirdFieldItem, doneButton, flexSpace, nil]];
	
	
	[spinner setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
	
	
	[self.view addSubview:titleBar];
	[self.view addSubview:webView];
	[self.view addSubview:toolBar];
	[self.view addSubview:spinner];

	return self;
	
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	textField.text = @"";
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	return YES;
}

- (void)done {
	
	if (!([firstField.text length] == 3 && [secondField.text length] == 3 && [thirdField.text length] == 3)) {
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Whoops!" message:@"After authorizing EOL Uploader, enter the 9-digit code from Flickr and tap \"Done\"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		
	} else {
	
		NSString *miniToken = [NSString stringWithFormat:@"%@-%@-%@", firstField.text, secondField.text, thirdField.text];
	
		[[self flickrController] authenticate:miniToken];
		
		[self.navigationController popViewControllerAnimated:YES];
		
	}
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if (range.location == 3) {
		if (textField.tag == 1) [secondField becomeFirstResponder];
		else if (textField.tag == 2) [thirdField becomeFirstResponder];
		else if (textField.tag == 3) return NO;
		return YES;
		
	} else if (range.location > 2) return NO;
	
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[spinner startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[spinner stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"You don't seem to have access to the internet.  You can still take photos and tag them. You can authenticate with flickr later through the settings menu." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];	
	[alert show];
	[alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	[self.navigationController popViewControllerAnimated:YES];
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
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
	[webView release];
	[toolBar release];
	[titleBar release];
	[spinner release];
    [super dealloc];
}



@end

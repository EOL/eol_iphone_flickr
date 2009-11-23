//
//  FlickrAuthViewController.h
//  cameraTest
//
//  Created by Charles Mezak on 12/3/08.
//  Natural Guides, LLC
//

#import <UIKit/UIKit.h>
#import "FlickrController.h"

@interface FlickrAuthViewController : UIViewController <UITextFieldDelegate, UIWebViewDelegate> {

	UIWebView				*webView;
	UIToolbar				*toolBar;
	UIToolbar				*titleBar;
	
	UITextField				*firstField;
	UITextField				*secondField;
	UITextField				*thirdField;
	
	FlickrController		*flickrController;
	
	UIActivityIndicatorView *spinner;	
	
}

@property (nonatomic, retain) UIWebView					*webView;
@property (nonatomic, retain) UIToolbar					*toolBar;
@property (nonatomic, retain) UIToolbar					*titleBar;
@property (nonatomic, retain) FlickrController			*flickrController;

@property (nonatomic, retain) UITextField				*firstField;
@property (nonatomic, retain) UITextField				*secondField;
@property (nonatomic, retain) UITextField				*thirdField;
@property (nonatomic, retain) UIActivityIndicatorView	*spinner;	


@end

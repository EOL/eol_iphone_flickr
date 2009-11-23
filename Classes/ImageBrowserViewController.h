//
//  ImageBrowserViewController.h
//  cameraTest
//
//  Created by Charles Mezak on 12/7/08.
//  Natural Guides, LLC
//

#import <UIKit/UIKit.h>
#import "FlickrController.h"
#import "DataController.h"
#import "EOLImage.h"
#import "ImageDetailViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "SettingsViewController.h"

@interface ImageBrowserViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate> {

	UIScrollView			*imageScrollView;
	FlickrController		*flickrController;
	DataController			*dataController;
	UIToolbar				*toolBar;
	UIImagePickerController	*imagePicker;
	
}

@property (nonatomic, retain)	UIScrollView			*imageScrollView;
@property (nonatomic, retain)	FlickrController		*flickrController;
@property (nonatomic, retain)	DataController			*dataController;
@property (nonatomic, retain)	UIToolbar				*toolBar;
@property (nonatomic, retain)	UIImagePickerController	*imagePicker;

- (void)reloadSubviews;
- (void)imageButtonPressed:(id)sender;
- (void)showDetailsForImage:(int)imageIndex;

@end

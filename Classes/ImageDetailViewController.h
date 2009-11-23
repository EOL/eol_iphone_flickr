//
//  ImageDetailViewController.h
//  cameraTest
//
//  Created by Charles Mezak on 12/7/08.
//  Natural Guides, LLC
//

#import <UIKit/UIKit.h>
#import "DataController.h"
#import "FlickrController.h"
#import "FlickrAuthViewController.h"

@interface ImageDetailViewController : UIViewController <EOLImageDelegate, UITextFieldDelegate> {

	UIImageView					*imageView;
	DataController				*dataController;
	FlickrController			*flickrController;
	EOLImage					*thisEOLImage;
	UIToolbar					*toolBar;
	int							imageIndex;
	UIActivityIndicatorView		*spinner;
	UIBarButtonItem				*spinnerBarButtonItem;
	UIBarButtonItem				*browseButton;
	UIBarButtonItem				*uploadButton;
	UIBarButtonItem				*goToFlickrButton;
	UIBarButtonItem				*deleteButton;
	UIBarButtonItem				*flexibleSpace;	
	UILabel						*locationLabel;
	UILabel						*dateLabel;
	UITextField					*commonField;
	UITextField					*binomialField;
}

@property (nonatomic, retain)	UIImageView					*imageView;
@property (nonatomic, retain)	DataController				*dataController;
@property (nonatomic, retain)	FlickrController			*flickrController;
@property (nonatomic, retain)	EOLImage					*thisEOLImage;
@property (nonatomic, retain)	UIToolbar					*toolBar;
@property (nonatomic)			int							imageIndex;
@property (nonatomic, retain)	UIActivityIndicatorView		*spinner;
@property (nonatomic, retain)	UIBarButtonItem				*spinnerBarButtonItem;
@property (nonatomic, retain)	UIBarButtonItem				*browseButton;
@property (nonatomic, retain)	UIBarButtonItem				*uploadButton;
@property (nonatomic, retain)	UIBarButtonItem				*deleteButton;
@property (nonatomic, retain)	UIBarButtonItem				*flexibleSpace;	
@property (nonatomic, retain)	UIBarButtonItem				*goToFlickrButton;
@property (nonatomic, retain)	UILabel						*locationLabel;
@property (nonatomic, retain)	UILabel						*dateLabel;
@property (nonatomic, retain)	UITextField					*commonField;
@property (nonatomic, retain)	UITextField					*binomialField;

- (id)initWithImageIndex:(int)anImageIndex;
- (void)backToBrowser;
- (void)updateInfo;

	
@end

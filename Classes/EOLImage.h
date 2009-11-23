//
//  EOLImage.h
//  cameraTest
//
//  Created by Charles Mezak on 11/26/08.
//  Natural Guides, LLC
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "FlickrController.h"
#import "DataController.h"

static NSString *caption = @"Taken with EOL on the iPhone";

@protocol EOLImageDelegate

- (void)imageDidUploadToFlickr;
- (void)imageDidUpdateLocation;

@end


@interface EOLImage : NSObject <CLLocationManagerDelegate> {
	
	id <EOLImageDelegate>	*delegate;
	NSDate					*date;
	float					latitude;
	float					longitude;
	NSString				*binomial;
	NSString				*common;
	NSString				*imageFileName;
	BOOL					uploaded;
	BOOL					locationSet;
	NSMutableString			*parseString;
	NSString				*flickrID;
	FlickrController		*flickrController;
}

@property(nonatomic, retain)	NSDate				*date;
@property(nonatomic)			float				latitude;
@property(nonatomic)			float				longitude;
@property(nonatomic)			BOOL				uploaded;
@property(nonatomic, retain)	NSString			*imageFileName;
@property(nonatomic, retain)	NSMutableString		*parseString;
@property(nonatomic, retain)	NSString			*flickrID;
@property(nonatomic, retain)	FlickrController	*flickrController;
@property(nonatomic, retain)	NSString			*binomial;
@property(nonatomic, retain)	NSString			*common;
@property(nonatomic)			BOOL					locationSet;


- (void)updateLocation;
- (id)initWithImageFileName:(NSString *)aFileName;
- (NSDictionary *)plistRepresentation;
- (id)initWithPlistRepresentation:(NSDictionary *)representation;
- (NSString *)thumbnailFileName;
- (NSString *)md5Digest:(NSString *)str;
- (NSURLRequest *)createPOSTRequest:(NSDictionary *)postKeys withData:(NSData *)data;
- (BOOL)upload;
- (void)uploadGeoInfo;
- (id)delegate;
- (void)setDelegate:(id)newDelegate;
- (void)sendToEOLGroup;
- (void)deleteFromFlickr;
- (NSString *)titleForUpload;
- (NSString *)tags;
- (NSURL *)URLOfImageOnFlickr;
- (void)setLicense;

@end


//
//  DataController.h
//  cameraTest
//
//  Created by Charles Mezak on 11/26/08.
//  Natural Guides, LLC
//

#import <Foundation/Foundation.h>
#import "EOLImage.h"
#import <CoreLocation/CoreLocation.h>

@interface DataController : NSObject <CLLocationManagerDelegate> {

	NSMutableArray		*EOLImages;
	CLLocationManager	*locationManager;
}

@property (nonatomic, retain)	NSMutableArray		*EOLImages;
@property (nonatomic, retain)	CLLocationManager	*locationManager;

- (void)saveData;
- (void)loadData;
- (int)imageCount;
- (void)deleteImage:(int)imageIndex FromFlickr:(BOOL)deleteFromFlickr;
- (NSString *)documentsDirectory;
- (void)addEOLImageWithImage:(UIImage *)image;
- (UIImage *)thumbnailImage:(UIImage *)image;
- (UIImage *)resizeImage:(UIImage *)image;
- (void)deleteAllEOLImages;


//singleton methods
+ (id)allocWithZone:(NSZone *)zone;
- (id)copyWithZone:(NSZone *)zone;
- (unsigned)retainCount;
- (void)release;
- (id)autorelease;
+ (DataController*)sharedController;

@end

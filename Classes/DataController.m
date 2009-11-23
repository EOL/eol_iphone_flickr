//
//  DataController.m
//  cameraTest
//
//  Created by Charles Mezak on 11/26/08.
//  Natural Guides, LLC
//

#import "DataController.h"
#include <math.h>
static inline double radians (double degrees) {return degrees * M_PI/180;}

@implementation DataController

@synthesize EOLImages, locationManager;

static DataController *sharedDataController = nil;

+ (DataController*)sharedController {
    @synchronized(self) {
        if (sharedDataController == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return sharedDataController;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedDataController == nil) {
            sharedDataController = [super allocWithZone:zone];
            return sharedDataController;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

- (id)init {
	self = [super init];
	
	locationManager = [[CLLocationManager alloc] init];
	EOLImages = [[NSMutableArray alloc] init];

	[self loadData];
	
	return self;
}

- (void)addEOLImage:(EOLImage *)newImage {
	[EOLImages addObject:newImage];
}

- (NSString *)documentsDirectory {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	
	return documentsDirectory;
}

- (void)loadData {
	
    NSString *path = [[self documentsDirectory] stringByAppendingPathComponent:@"/Images.plist"];
	
	NSData *plistData;
	NSString *error;
	NSPropertyListFormat format;
	NSArray *plist;
	plistData = [NSData dataWithContentsOfFile:path];
	
	plist = [NSPropertyListSerialization propertyListFromData:plistData mutabilityOption:NSPropertyListImmutable format:&format errorDescription:&error];
	
	if(!plist)
	{
		NSLog(error);
		[error release];
	}	
	
	EOLImage *newImage;
	
	NSLog([NSString stringWithFormat:@"%d representations in plist", [plist count]]);
	
	for (int i = 0; i < [plist count]; i++) {
		newImage = [[EOLImage alloc] initWithPlistRepresentation:[plist objectAtIndex:i]];
		[EOLImages addObject:newImage];
	}
	
	NSLog([NSString stringWithFormat:@"found %d saved images", [EOLImages count]]);
	
}

- (void)saveData {
	
	//build the plist representation of the images
	NSMutableArray *plistImages = [NSMutableArray array];
	
	for (int i = 0; i < [EOLImages count]; i++) {
		[plistImages addObject:[[EOLImages objectAtIndex:i] plistRepresentation]];
	}
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"/Images.plist"];
	NSData *xmlData;
	NSString *error;
	
	xmlData = [NSPropertyListSerialization dataFromPropertyList:plistImages format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
	
	if(xmlData)
	{
		[xmlData writeToFile:path atomically:YES];
	}
	else
	{
		NSLog(error);
		[error release];
	}
}

- (int)imageCount {
	return [EOLImages count];
}

- (void)dealloc {
	[EOLImages release];
	[locationManager release];
	[super dealloc];
	
}

- (void)deleteImage:(int)imageIndex FromFlickr:(BOOL)deleteFromFlickr {
	
	EOLImage *imageToDelete = [EOLImages objectAtIndex:imageIndex];
	
	if (deleteFromFlickr) {
		NSLog(@"deleting image from flickr");
		[imageToDelete deleteFromFlickr];
	}
	
	//first delete the image file
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	[fileManager removeItemAtPath:[imageToDelete imageFileName] error:nil];
	[fileManager removeItemAtPath:[imageToDelete thumbnailFileName] error:nil];

	[EOLImages removeObject:imageToDelete];
}

- (void)addEOLImageWithImage:(UIImage *)image {
	
	NSLog(@"DataController: adding new EOL Image");
	
	int now = [[NSDate date] timeIntervalSince1970];
	
	//
	// save the new image to the documents directory
	//
	NSString *imageName = [NSString stringWithFormat:@"%d.jpg", now];
	NSString *thumbName = [NSString stringWithFormat:@"%dthumb.jpg", now];
	
	//write the full image
    NSString *path = [[self documentsDirectory] stringByAppendingPathComponent:imageName];
	
	NSData *imageData = UIImageJPEGRepresentation([self resizeImage:image], 1);
	
	[imageData writeToFile:path atomically:YES];
	
	// write thumbnail
	path = [[self documentsDirectory] stringByAppendingPathComponent:thumbName];
		
	imageData = UIImageJPEGRepresentation([self thumbnailImage:image], 1);
	
	[imageData writeToFile:path atomically:YES];
	
	//
	// create a new EOL Image and send it to the data controller
	//
	
	EOLImage *newEOLImage = [[EOLImage alloc] initWithImageFileName:imageName];
	
	[EOLImages addObject:newEOLImage];
	
	[newEOLImage updateLocation];
	
}

- (UIImage *)thumbnailImage:(UIImage *)image {
	
	CGImageRef imageRef = [image CGImage];
	CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
	CGColorSpaceRef colorSpaceInfo = CGColorSpaceCreateDeviceRGB();
	
	if (alphaInfo == kCGImageAlphaNone)
		alphaInfo = kCGImageAlphaNoneSkipLast;
	
	int width, height;
	
	width = 640;
	height = 480;
	
	CGContextRef bitmap;
	
	if (image.imageOrientation == UIImageOrientationUp | image.imageOrientation == UIImageOrientationDown) {
		bitmap = CGBitmapContextCreate(NULL, width, height, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, alphaInfo);
		
	} else {
		bitmap = CGBitmapContextCreate(NULL, height, width, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, alphaInfo);
		
	}
	
	CGColorSpaceRelease(colorSpaceInfo);
	
	if (image.imageOrientation == UIImageOrientationLeft) {
		NSLog(@"image orientation left");
		CGContextRotateCTM (bitmap, radians(90));
		CGContextTranslateCTM (bitmap, 0, -height);
		
	} else if (image.imageOrientation == UIImageOrientationRight) {
		NSLog(@"image orientation right");
		CGContextRotateCTM (bitmap, radians(-90));
		CGContextTranslateCTM (bitmap, -width, 0);
		
	} else if (image.imageOrientation == UIImageOrientationUp) {
		NSLog(@"image orientation up");	
		
	} else if (image.imageOrientation == UIImageOrientationDown) {
		NSLog(@"image orientation down");	
		CGContextTranslateCTM (bitmap, width,height);
		CGContextRotateCTM (bitmap, radians(-180.));
		
	}
	
	CGContextDrawImage(bitmap, CGRectMake(0, 0, width, height), imageRef);
	
	
	CGImageRef bitmapImage = CGBitmapContextCreateImage(bitmap);
	//CGImageRelease(imageRef);

	CGContextRelease(bitmap);

	CGImageRef squareClip;
	
	if (height > width) {
		squareClip = CGImageCreateWithImageInRect(bitmapImage, CGRectMake(0, 0, width, width));
		
	} else {
		squareClip = CGImageCreateWithImageInRect(bitmapImage, CGRectMake(0, 0, height, height));
		
	}
	
	CGImageRelease(bitmapImage);
	
	bitmap = CGBitmapContextCreate(NULL, 100, 100, CGImageGetBitsPerComponent(squareClip), CGImageGetBytesPerRow(squareClip), CGImageGetColorSpace(squareClip), alphaInfo);
	CGContextDrawImage(bitmap, CGRectMake(0, 0, 100, 100), squareClip);
	CGImageRelease(squareClip);

	CGImageRef ref = CGBitmapContextCreateImage(bitmap);
	CGContextRelease(bitmap);

	UIImage *result = [UIImage imageWithCGImage:ref];
	CGImageRelease(ref);
	
	return result;	
}

- (void)deleteAllEOLImages {
	
	NSLog(@"removing all EOL images");
	
	NSFileManager	*fileManager = [NSFileManager defaultManager];
	NSString		*pathOfFileToRemove;
	EOLImage		*thisEOLImage;
	
	
	for (int i = 0; i < [EOLImages count]; i++) {
		thisEOLImage = [EOLImages objectAtIndex:i];
		
		pathOfFileToRemove = [[self documentsDirectory] stringByAppendingPathComponent:[thisEOLImage imageFileName]];
		
		[fileManager removeItemAtPath:pathOfFileToRemove error:nil];
		
		pathOfFileToRemove = [[self documentsDirectory] stringByAppendingPathComponent:[thisEOLImage thumbnailFileName]];
		
		[fileManager removeItemAtPath:pathOfFileToRemove error:nil];
				
	}
	
	[EOLImages removeAllObjects];
	
	NSLog(@"removed all EOL Images");
	
}

-(UIImage *)resizeImage:(UIImage *)image {
	
	CGImageRef imageRef = [image CGImage];
	CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
	CGColorSpaceRef colorSpaceInfo = CGColorSpaceCreateDeviceRGB();
	
	if (alphaInfo == kCGImageAlphaNone)
		alphaInfo = kCGImageAlphaNoneSkipLast;
	
	int width, height;
	
	width = 640;
	height = 480;
	
	CGContextRef bitmap;
	
	if (image.imageOrientation == UIImageOrientationUp | image.imageOrientation == UIImageOrientationDown) {
		bitmap = CGBitmapContextCreate(NULL, width, height, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, alphaInfo);
		
	} else {
		bitmap = CGBitmapContextCreate(NULL, height, width, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, alphaInfo);
		
	}
	
	if (image.imageOrientation == UIImageOrientationLeft) {
		NSLog(@"image orientation left");
		CGContextRotateCTM (bitmap, radians(90));
		CGContextTranslateCTM (bitmap, 0, -height);
		
	} else if (image.imageOrientation == UIImageOrientationRight) {
		NSLog(@"image orientation right");
		CGContextRotateCTM (bitmap, radians(-90));
		CGContextTranslateCTM (bitmap, -width, 0);
		
	} else if (image.imageOrientation == UIImageOrientationUp) {
		NSLog(@"image orientation up");	
		
	} else if (image.imageOrientation == UIImageOrientationDown) {
		NSLog(@"image orientation down");	
		CGContextTranslateCTM (bitmap, width,height);
		CGContextRotateCTM (bitmap, radians(-180.));
		
	}
	
	CGContextDrawImage(bitmap, CGRectMake(0, 0, width, height), imageRef);
	CGImageRef ref = CGBitmapContextCreateImage(bitmap);
	UIImage *result = [UIImage imageWithCGImage:ref];
	
	CGContextRelease(bitmap);
	CGImageRelease(ref);
	//CGImageRelease(imageRef);
	
	return result;	
}


@end

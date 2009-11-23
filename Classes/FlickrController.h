//
//  FlickrController.h
//  cameraTest
//
//  Created by Charles Mezak on 12/3/08.
//  Natural Guides, LLC
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface FlickrController : NSObject {
	
	NSString		*token;
	NSString		*sharedSecret;
	NSString		*apiKey;
	NSString		*EOLGroupID;
	NSString		*nsid;
	
	NSMutableString	*parseString;
	
	NSURLConnection *connection;
	NSMutableData	*receivedData;
	
	int				licenseID;
	
}

@property (nonatomic, retain)	NSString		*token;
@property (nonatomic, retain)	NSString		*sharedSecret;
@property (nonatomic, retain)	NSString		*apiKey;
@property (nonatomic, retain)	NSMutableString	*parseString;
@property (nonatomic, retain)	NSURLConnection *connection;
@property (nonatomic, retain)	NSMutableData	*receivedData;
@property (nonatomic, retain)	NSString		*EOLGroupID;
@property (nonatomic, retain)	NSString		*nsid;
@property (nonatomic)			int				licenseID;


- (id)init;
- (void)authenticate:(NSString *)miniToken;
+ (FlickrController*)sharedController;
- (NSString *)md5Digest:(NSString *)str;
+ (id)allocWithZone:(NSZone *)zone;
- (id)copyWithZone:(NSZone *)zone;
- (unsigned)retainCount;
- (void)release;
- (id)autorelease;
- (NSString *)generateSignatureForUpload;
- (BOOL)uploadImage:(NSString *)photo withCaption:(NSString *)caption;
-(NSURLRequest *)createPOSTRequest:(NSDictionary *)postKeys withData:(NSData *)data;
- (void)getUserURL;
- (void)saveData;
- (void)loadData;

@end

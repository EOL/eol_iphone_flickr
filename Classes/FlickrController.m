//
//  FlickrController.m
//  cameraTest
//
//  Created by Charles Mezak on 12/3/08.
//  Natural Guides, LLC
//

#import "FlickrController.h"


@implementation FlickrController

@synthesize apiKey, token, sharedSecret, parseString, connection, receivedData, EOLGroupID, nsid, licenseID;

static FlickrController *sharedFlickrController = nil;

+ (FlickrController*)sharedController {
    @synchronized(self) {
        if (sharedFlickrController == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return sharedFlickrController;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedFlickrController == nil) {
            sharedFlickrController = [super allocWithZone:zone];
            return sharedFlickrController;  // assignment and return on first allocation
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
	
	token = nil;
	
	[self loadData];
	
	apiKey = @"19cb4f7bd8afdbee22c819969323421c";
	sharedSecret = @"db451fa53c9aeb3f";
	EOLGroupID = @"806927@N20";
	
	parseString = [[NSMutableString alloc] initWithString:@""];
	
	
	return self;
}

- (void)authenticate:(NSString *)miniToken {
		
	NSLog(@"authenticating with flickr");
	
	NSLog(@"mini_token:");
	NSLog(miniToken);
	
	NSString *signatureString = [NSString stringWithFormat:@"%@api_key%@methodflickr.auth.getFullTokenmini_token%@", sharedSecret, apiKey, miniToken];
	
	NSLog(@"signature string:");
	NSLog(signatureString);
	
	NSString *api_sig = [self md5Digest:signatureString];
	
	//create the URL string with the method given as well as the static api key and the signature just generated
	NSMutableString *URLString = [NSMutableString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.auth.getFullToken&api_key=%@&api_sig=%@&mini_token=%@", apiKey, api_sig, miniToken];
	
	//send the request!
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:URLString]];
	[parser setDelegate:self];
	[parser parse];
	[parser release];
}

- (void)getUserURL {
	
	NSLog(@"getting user name from flickr");
	
	//create the URL string with the method given as well as the static api key
	NSMutableString *URLString = [NSMutableString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.urls.getUserPhotos&api_key=%@", apiKey];
	
	//send the request!
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:URLString]];
	[parser setDelegate:self];
	[parser parse];
	[parser release];
}

- (NSString *)generateSignatureForUpload {
	
	NSMutableString *signatureString = [NSMutableString stringWithFormat:@"%@api_key%@auth_token%@", sharedSecret, apiKey, token];

	NSLog(@"Generated Upload Signature String:");
	NSLog(signatureString);
	
	NSString *apiSig = [self md5Digest:signatureString];
	
	NSLog(@"Generated Upload Signature:");
	NSLog(apiSig);
	
	return apiSig;
}

- (NSString *)md5Digest:(NSString *)str {
	const char *cStr = [str UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5( cStr, strlen(cStr), result );
	return [NSString stringWithFormat:
			@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
			];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	
	if (qName) {
        elementName = qName;
    }
    if ([elementName isEqualToString:@"token"]) {	
		if (parseString) [parseString release];
		parseString = [[NSMutableString alloc] initWithString:@""];
	} else if ([elementName isEqualToString:@"user"]) {
		//get the user name
		self.nsid = [attributeDict objectForKey:@"nsid"];
		NSLog(@"got user nsid and url:");
		NSLog(nsid);
	}
	
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if (qName) {
        elementName = qName;
    }
    if ([elementName isEqualToString:@"token"]) {
		//get the token
		self.token = [parseString copy];
		NSLog(@"Got Auth Token:");
		NSLog(self.token);
		[self getUserURL];
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	[parseString appendString:string];
}

- (BOOL)uploadImage:(NSString *)photo withCaption:(NSString *)caption {
	//get image data from file
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:photo];
	
	NSData *imageData = [NSData dataWithContentsOfFile:path];	
	//stop on error
	if (!imageData) return NO;
	
	//Create dictionary of post arguments
	NSMutableDictionary *keysDict = [NSMutableDictionary dictionary];
	[keysDict setObject:apiKey forKey:@"api_key"];
	[keysDict setObject:self.token forKey:@"auth_token"];
	
	//create tumblr photo post
	NSURLRequest *tumblrPost = [self createPOSTRequest:keysDict withData:imageData];
	
	//send request, return YES if successful
	connection = [[NSURLConnection alloc] initWithRequest:tumblrPost delegate:self];
	if (!connection) {
		NSLog(@"Failed to submit request");
		return NO;
	} else {
		NSLog(@"Request submitted");
		receivedData = [[NSMutableData data] retain];
		return YES;
	}
}

-(NSURLRequest *)createPOSTRequest:(NSDictionary *)postKeys withData:(NSData *)data {
	//create the URL POST Request to tumblr
	NSURL *tumblrURL = [NSURL URLWithString:@"http://api.flickr.com/services/upload/"];
	NSMutableURLRequest *tumblrPost = [NSMutableURLRequest requestWithURL:tumblrURL];
	[tumblrPost setHTTPMethod:@"POST"];
	
	//Add the header info
	NSString *stringBoundary = [NSString stringWithString:@"---------------------------0xKhTmLbOuNdArY"];
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",stringBoundary];
	[tumblrPost addValue:contentType forHTTPHeaderField: @"Content-Type"];
	[tumblrPost addValue:@"multipart/form-data" forHTTPHeaderField:@"enctype"];
	[tumblrPost addValue:@"api.flickr.com" forHTTPHeaderField:@"Host"];
	[tumblrPost addValue:[NSString stringWithFormat:@"%d", [data length]] forHTTPHeaderField:@"Content-length"];
	
	//create the body
	NSMutableData *postBody = [NSMutableData data];
	[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	//add api_key
	[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"api_key"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[apiKey dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	//add auth_token
	[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"auth_token"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[token dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	//add signature
	[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"api_sig"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[self generateSignatureForUpload] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	//add data field and file data
	[postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"photo\"; fileName=\"hello.jpg\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:@"Content-Type: image/jpeg\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[NSData dataWithData:data]];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	
	//add the body to the post
	[tumblrPost setHTTPBody:postBody];
	
	return tumblrPost;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog([error description]);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	NSLog(@"got response");
	
	
	
	
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	NSLog(@"received data");
	
	NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSLog(dataString);
	[dataString release];

}

- (void)loadData {
	
	NSLog(@"loading token");
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:@"/UserInfo.plist"];
	
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
	
	token = [[(NSDictionary *)plist objectForKey:@"token"] copy];
	nsid = [[(NSDictionary *)plist objectForKey:@"nsid"] copy];
	licenseID = [[(NSDictionary *)plist objectForKey:@"licenseID"] intValue];
	
	
}

- (void)saveData {
	
	if (token) {
		
		NSLog(@"saving token");
		
		//build the plist representation of the images
		NSMutableDictionary *info = [NSMutableDictionary dictionary];
		
		[info setObject:token forKey:@"token"];
		[info setObject:nsid forKey:@"nsid"];
		[info setObject:[NSNumber numberWithInt:licenseID] forKey:@"licenseID"];
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *path = [documentsDirectory stringByAppendingPathComponent:@"/UserInfo.plist"];
		NSData *xmlData;
		NSString *error;
		
		xmlData = [NSPropertyListSerialization dataFromPropertyList:info format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
		
		if(xmlData)
		{
			[xmlData writeToFile:path atomically:YES];
		}
		else
		{
			NSLog(error);
			[error release];
		}
	} else NSLog(@"no token to save");
}

@end

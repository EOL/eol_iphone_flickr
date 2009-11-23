//
//  EOLImage.m
//  cameraTest
//
//  Created by Charles Mezak on 11/26/08.
//  Natural Guides, LLC
//

#import "EOLImage.h"


@implementation EOLImage

@synthesize date, latitude, longitude, binomial, common, uploaded, imageFileName, parseString, flickrID, flickrController, locationSet;

- (id)initWithImageFileName:(NSString *)aFileName {
	
	self = [super init];

	flickrController = [FlickrController sharedController];
	delegate = nil;
	
	self.locationSet = NO;
	self.date = [NSDate date];
	self.latitude = 0;
	self.longitude = 0;
	self.common = @"";
	self.binomial = @"";
	self.imageFileName = aFileName;
	self.flickrID = @"none";
	
	return self;
}

- (void)updateLocation {
	NSLog(@"eol image will update location");
	CLLocationManager *manager = [[DataController sharedController] locationManager];
	[manager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
	[manager setDelegate:self];
	[manager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	
	
	NSLog(@"got location");
	
	latitude =		newLocation.coordinate.latitude;
	longitude =		newLocation.coordinate.longitude;
	
	[delegate imageDidUpdateLocation];
	
	NSLog([NSString stringWithFormat:@"updated location with latitude: %f and longitude: %f", latitude, longitude]);
	
	locationSet = YES;
	
	[manager stopUpdatingLocation];	
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {	
	NSLog(@"location update failed");
	if ([error code] == kCLErrorDenied) [manager stopUpdatingLocation];
	else if ([error code] == kCLErrorLocationUnknown) {
		[manager stopUpdatingLocation];
		// open an alert with just an OK button
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Whoops!" message:@"Your GPS location could not be determined.  Try again."
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
		[alert release];
	}
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	if (qName) {
        elementName = qName;
    }
    if ([elementName isEqualToString:@"name"]) {	
		if (parseString) [parseString release];
		parseString = [[NSMutableString alloc] initWithString:@""];
	}
	if ([elementName isEqualToString:@"photoid"]) {	
		if (parseString) [parseString release];
		parseString = [[NSMutableString alloc] initWithString:@""];

	}
	
	
	NSLog(qName);
	
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if (qName) {
        elementName = qName;
    }

	if ([elementName isEqualToString:@"photoid"]) {	
		flickrID = [parseString copy];
		NSLog(@"got photo id");
		NSLog(flickrID);
		[self uploadGeoInfo];
		[self sendToEOLGroup];
		[self setLicense];
		uploaded = YES;
		[delegate imageDidUploadToFlickr];
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	[parseString appendString:string];
}

- (NSDictionary *)plistRepresentation {
	NSMutableDictionary *temp = [NSMutableDictionary dictionary];
	
	[temp setObject:self.date forKey:@"date"];
	[temp setObject:[NSNumber numberWithFloat:self.latitude] forKey:@"latitude"];
	[temp setObject:[NSNumber numberWithFloat:self.longitude] forKey:@"longitude"];
	[temp setObject:self.binomial forKey:@"binomial"];
	[temp setObject:self.common forKey:@"common"];
	[temp setObject:self.imageFileName forKey:@"fileName"];
	[temp setObject:[NSNumber numberWithBool:uploaded] forKey:@"uploaded"];
	[temp setObject:[NSNumber numberWithBool:locationSet] forKey:@"locationSet"];
	[temp setObject:flickrID forKey:@"flickrID"];
	NSLog(@"saving image with filepath:");
	NSLog(imageFileName);
	
	return temp;
	
}

- (id)initWithPlistRepresentation:(NSDictionary *)representation {
	
	self = [super init];
	
	flickrController = [FlickrController sharedController];
	delegate = nil;	
	
	self.date = [representation objectForKey:@"date"];
	self.latitude = [[representation objectForKey:@"latitude"] floatValue];
	self.longitude = [[representation objectForKey:@"longitude"] floatValue];
	self.common = [representation objectForKey:@"common"];
	self.binomial = [representation objectForKey:@"binomial"];
	self.imageFileName = [representation objectForKey:@"fileName"];
	self.uploaded = [[representation objectForKey:@"uploaded"] boolValue];
	self.locationSet = [[representation objectForKey:@"locationSet"] boolValue];
	self.flickrID = [representation objectForKey:@"flickrID"];
		
	return self;
	
}

- (NSString *)thumbnailFileName {
	
	NSMutableString *thumbName = [NSMutableString stringWithString:imageFileName];
	[thumbName insertString:@"thumb" atIndex:[thumbName length] - 4];
	
	return thumbName;
}


- (NSString *)generateSignatureForUpload {
	
	NSMutableString *signatureString = [NSMutableString stringWithFormat:@"%@api_key%@auth_token%@description%@tags%@title%@", [flickrController sharedSecret], [flickrController apiKey], [flickrController token], caption, [self tags], [self titleForUpload]];
	
	NSLog(@"Generated Upload Signature String:");
	NSLog(signatureString);
	
	NSString *apiSig = [self md5Digest:signatureString];
	
	NSLog(@"Generated Upload Signature:");
	NSLog(apiSig);
	
	return apiSig;
}

- (NSString *)generateSignatureForGeotagging {
	
	NSMutableString *signatureString = [NSMutableString stringWithFormat:@"%@api_key%@auth_token%@lat%@lon%@methodflickr.photos.geo.setLocationphoto_id%@", [flickrController sharedSecret], [flickrController apiKey], [flickrController token], [NSString stringWithFormat:@"%f", latitude], [NSString stringWithFormat:@"%f", longitude], flickrID];
	
	NSLog(@"Generated geotag Signature String:");
	NSLog(signatureString);
	
	NSString *apiSig = [self md5Digest:signatureString];
	
	NSLog(@"Generated geotag Signature:");
	NSLog(apiSig);
	
	return apiSig;
}

- (NSString *)generateSignatureForDeletion {
	
	NSMutableString *signatureString = [NSMutableString stringWithFormat:@"%@api_key%@auth_token%@methodflickr.photos.deletephoto_id%@", [flickrController sharedSecret], [flickrController apiKey], [flickrController token], flickrID];
	
	NSLog(@"Generated delete Signature String:");
	NSLog(signatureString);
	
	NSString *apiSig = [self md5Digest:signatureString];
	
	NSLog(@"Generated delete Signature:");
	NSLog(apiSig);
	
	return apiSig;
}

- (NSString *)generateSignatureForGroupSend {
	
	NSMutableString *signatureString = [NSMutableString stringWithFormat:@"%@api_key%@auth_token%@group_id%@methodflickr.groups.pools.addphoto_id%@", [flickrController sharedSecret], [flickrController apiKey], [flickrController token], [flickrController EOLGroupID], flickrID];
	
	NSLog(@"Generated groupsend Signature String:");
	NSLog(signatureString);
	
	NSString *apiSig = [self md5Digest:signatureString];
	
	NSLog(@"Generated groupsend Signature:");
	NSLog(apiSig);
	
	return apiSig;
}

- (NSString *)generateSignatureForLicense {
	
	NSMutableString *signatureString = [NSMutableString stringWithFormat:@"%@api_key%@auth_token%@license_id4methodflickr.photos.licenses.setLicensephoto_id%@", [flickrController sharedSecret], [flickrController apiKey], [flickrController token], flickrID];
	
	NSLog(@"Generated license Signature String:");
	NSLog(signatureString);
	
	NSString *apiSig = [self md5Digest:signatureString];
	
	NSLog(@"Generated license Signature:");
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

- (void)deleteFromFlickr {
	
	//create the URL POST Request to tumblr
	NSURL *tumblrURL = [NSURL URLWithString:@"http://api.flickr.com/services/soap/"];
	NSMutableURLRequest *tumblrPost = [NSMutableURLRequest requestWithURL:tumblrURL];
	[tumblrPost setHTTPMethod:@"POST"];
	
	//Add the header info
	NSString *contentType = [NSString stringWithFormat:@"text/xml; charset=UTF-8"];
	[tumblrPost addValue:contentType forHTTPHeaderField: @"Content-Type"];
	[tumblrPost addValue:@"multipart/form-data" forHTTPHeaderField:@"enctype"];
	[tumblrPost addValue:@"api.flickr.com" forHTTPHeaderField:@"Host"];
	
	NSMutableString *soapMessage = [NSMutableString stringWithString:@"<s:Envelope xmlns:s=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:xsi=\"http://www.w3.org/1999/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/1999/XMLSchema\"> <s:Body> <x:FlickrRequest xmlns:x=\"urn:flickr\">"];
	
	//add method
	[soapMessage appendString:@"<method>\n"];
	[soapMessage appendString:@"flickr.photos.delete\n"];
	[soapMessage appendString:@"</method>\n"];
	
	//add api_key
	[soapMessage appendString:@"<api_key>\n"];
	[soapMessage appendString:[flickrController apiKey]];
	[soapMessage appendString:@"</api_key>\n"];
	
	//add auth_token
	[soapMessage appendString:@"<auth_token>\n"];
	[soapMessage appendString:[flickrController token]];
	[soapMessage appendString:@"</auth_token>\n"];
	
	//add photo id
	[soapMessage appendString:@"<photo_id>\n"];
	[soapMessage appendString:flickrID];
	[soapMessage appendString:@"</photo_id>\n"];

	//add signature
	[soapMessage appendString:@"<api_sig>\n"];
	[soapMessage appendString:[self generateSignatureForDeletion]];
	[soapMessage appendString:@"</api_sig>\n"];
	
	[soapMessage appendString:@"</x:FlickrRequest> </s:Body> </s:Envelope>"];
	
	NSLog(soapMessage);
	
	//add the body to the post
	[tumblrPost setHTTPBody:[soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
	
	[tumblrPost addValue:[NSString stringWithFormat:@"%d",[soapMessage length]] forHTTPHeaderField:@"Content-length"];
	
	//send request, return YES if successful
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:tumblrPost delegate:self];
	if (!connection) {
		NSLog(@"Failed to submit delete request");
	} else {
		NSLog(@"delete Request submitted");
	}
	
	
}

- (BOOL)upload {
	//get image data from file
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:imageFileName];
	
	NSData *imageData = [NSData dataWithContentsOfFile:path];	
	//stop on error
	if (!imageData) return NO;
	
	//Create dictionary of post arguments
	NSMutableDictionary *keysDict = [NSMutableDictionary dictionary];
	[keysDict setObject:[flickrController apiKey] forKey:@"api_key"];
	[keysDict setObject:[flickrController token] forKey:@"auth_token"];
	
	//create tumblr photo post
	NSURLRequest *tumblrPost = [self createPOSTRequest:keysDict withData:imageData];
	
	//send request, return YES if successful
	NSURLConnection *connection = [[[NSURLConnection alloc] initWithRequest:tumblrPost delegate:self] autorelease];
	if (!connection) {
		NSLog(@"Failed to submit request");
		return NO;
	} else {
		NSLog(@"Request submitted");
		return YES;
	}
}

-(NSURLRequest *)createPOSTRequest:(NSDictionary *)postKeys withData:(NSData *)data
{
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
	[postBody appendData:[[flickrController apiKey] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	//add auth_token
	[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"auth_token"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[flickrController token] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	//add title
	[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"title"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[self titleForUpload] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	//add description
	[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"description"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[caption dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	//add tags
	[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"tags"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[self tags] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	//add signature
	[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"api_sig"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[self generateSignatureForUpload] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	//add data field and file data
	[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"photo\"; fileName=\"%@.jpg\"\r\n", [self titleForUpload]] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:@"Content-Type: image/jpeg\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[NSData dataWithData:data]];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	
	//add the body to the post
	[tumblrPost setHTTPBody:postBody];
	
	return tumblrPost;
}

- (NSString *)tags {
	
	NSLog(@"names:");
	NSLog(common);
	NSLog(binomial);
	
	NSMutableString *tags = [NSMutableString string];
	
	if (![binomial isEqualToString:@""]) [tags appendString:[NSString stringWithFormat:@"taxonomy:binomial=\"%@\"", binomial]];
	if (![common isEqualToString:@""]) [tags appendString:[NSString stringWithFormat:@" taxonomy:common=\"%@\"", common]];

	NSLog(@"image tags:");
	NSLog(tags);
	
	return tags;
}

- (void)uploadGeoInfo {

	//create the URL POST Request to tumblr
	NSURL *tumblrURL = [NSURL URLWithString:@"http://api.flickr.com/services/soap/"];
	NSMutableURLRequest *tumblrPost = [NSMutableURLRequest requestWithURL:tumblrURL];
	[tumblrPost setHTTPMethod:@"POST"];
	
	//Add the header info
	NSString *contentType = [NSString stringWithFormat:@"text/xml; charset=UTF-8"];
	[tumblrPost addValue:contentType forHTTPHeaderField: @"Content-Type"];
	[tumblrPost addValue:@"multipart/form-data" forHTTPHeaderField:@"enctype"];
	[tumblrPost addValue:@"api.flickr.com" forHTTPHeaderField:@"Host"];

	NSMutableString *soapMessage = [NSMutableString stringWithString:@"<s:Envelope xmlns:s=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:xsi=\"http://www.w3.org/1999/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/1999/XMLSchema\"> <s:Body> <x:FlickrRequest xmlns:x=\"urn:flickr\">"];
	
	//add method
	[soapMessage appendString:@"<method>\n"];
	[soapMessage appendString:@"flickr.photos.geo.setLocation\n"];
	[soapMessage appendString:@"</method>\n"];
	
	//add api_key
	[soapMessage appendString:@"<api_key>\n"];
	[soapMessage appendString:[flickrController apiKey]];
	[soapMessage appendString:@"</api_key>\n"];
	
	//add auth_token
	[soapMessage appendString:@"<auth_token>\n"];
	[soapMessage appendString:[flickrController token]];
	[soapMessage appendString:@"</auth_token>\n"];
	
	//add photo id
	[soapMessage appendString:@"<photo_id>\n"];
	[soapMessage appendString:flickrID];
	[soapMessage appendString:@"</photo_id>\n"];
	
	//add latitude
	[soapMessage appendString:@"<lat>\n"];
	[soapMessage appendString:[NSString stringWithFormat:@"%f\n", latitude]];
	[soapMessage appendString:@"</lat>\n"];
	
	//add longitude
	[soapMessage appendString:@"<lon>\n"];
	[soapMessage appendString:[NSString stringWithFormat:@"%f\n", longitude]];
	[soapMessage appendString:@"</lon>\n"];
	
	//add signature
	[soapMessage appendString:@"<api_sig>\n"];
	[soapMessage appendString:[self generateSignatureForGeotagging]];
	[soapMessage appendString:@"</api_sig>\n"];
	
	[soapMessage appendString:@"</x:FlickrRequest> </s:Body> </s:Envelope>"];
	
	NSLog(soapMessage);
	
	//add the body to the post
	[tumblrPost setHTTPBody:[soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
	
	[tumblrPost addValue:[NSString stringWithFormat:@"%d",[soapMessage length]] forHTTPHeaderField:@"Content-length"];
	
	//send request, return YES if successful
	NSURLConnection *connection = [[[NSURLConnection alloc] initWithRequest:tumblrPost delegate:self] autorelease];
	if (!connection) {
		NSLog(@"Failed to submit geotag request");
	} else {
		NSLog(@"geotag Request submitted");
	}
	
}

- (void)sendToEOLGroup {
	
	//create the URL POST Request to tumblr
	NSURL *tumblrURL = [NSURL URLWithString:@"http://api.flickr.com/services/soap/"];
	NSMutableURLRequest *tumblrPost = [NSMutableURLRequest requestWithURL:tumblrURL];
	[tumblrPost setHTTPMethod:@"POST"];
	
	//Add the header info
	NSString *contentType = [NSString stringWithFormat:@"text/xml; charset=UTF-8"];
	[tumblrPost addValue:contentType forHTTPHeaderField: @"Content-Type"];
	[tumblrPost addValue:@"multipart/form-data" forHTTPHeaderField:@"enctype"];
	[tumblrPost addValue:@"api.flickr.com" forHTTPHeaderField:@"Host"];
	
	NSMutableString *soapMessage = [NSMutableString stringWithString:@"<s:Envelope xmlns:s=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:xsi=\"http://www.w3.org/1999/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/1999/XMLSchema\"> <s:Body> <x:FlickrRequest xmlns:x=\"urn:flickr\">"];
	
	//add method
	[soapMessage appendString:@"<method>\n"];
	[soapMessage appendString:@"flickr.groups.pools.add\n"];
	[soapMessage appendString:@"</method>\n"];
	
	//add api_key
	[soapMessage appendString:@"<api_key>\n"];
	[soapMessage appendString:[flickrController apiKey]];
	[soapMessage appendString:@"</api_key>\n"];
	
	//add auth_token
	[soapMessage appendString:@"<auth_token>\n"];
	[soapMessage appendString:[flickrController token]];
	[soapMessage appendString:@"</auth_token>\n"];
	
	//add photo id
	[soapMessage appendString:@"<photo_id>\n"];
	[soapMessage appendString:flickrID];
	[soapMessage appendString:@"</photo_id>\n"];
	
	//add group_id
	[soapMessage appendString:@"<group_id>\n"];
	[soapMessage appendString:[flickrController EOLGroupID]];
	[soapMessage appendString:@"</group_id>\n"];
	
	//add signature
	[soapMessage appendString:@"<api_sig>\n"];
	[soapMessage appendString:[self generateSignatureForGroupSend]];
	[soapMessage appendString:@"</api_sig>\n"];
	
	[soapMessage appendString:@"</x:FlickrRequest> </s:Body> </s:Envelope>"];
	
	NSLog(soapMessage);
	
	//add the body to the post
	[tumblrPost setHTTPBody:[soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
	
	[tumblrPost addValue:[NSString stringWithFormat:@"%d",[soapMessage length]] forHTTPHeaderField:@"Content-length"];
	
	//send request, return YES if successful
	NSURLConnection *connection = [[[NSURLConnection alloc] initWithRequest:tumblrPost delegate:self] autorelease];
	if (!connection) {
		NSLog(@"Failed to submit groupsend request");
	} else {
		NSLog(@"groupsend Request submitted");
	}
	
}

- (void)setLicense {
	
	//create the URL POST Request to tumblr
	NSURL *tumblrURL = [NSURL URLWithString:@"http://api.flickr.com/services/soap/"];
	NSMutableURLRequest *tumblrPost = [NSMutableURLRequest requestWithURL:tumblrURL];
	[tumblrPost setHTTPMethod:@"POST"];
	
	//Add the header info
	NSString *contentType = [NSString stringWithFormat:@"text/xml; charset=UTF-8"];
	[tumblrPost addValue:contentType forHTTPHeaderField: @"Content-Type"];
	[tumblrPost addValue:@"multipart/form-data" forHTTPHeaderField:@"enctype"];
	[tumblrPost addValue:@"api.flickr.com" forHTTPHeaderField:@"Host"];
	
	NSMutableString *soapMessage = [NSMutableString stringWithString:@"<s:Envelope xmlns:s=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:xsi=\"http://www.w3.org/1999/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/1999/XMLSchema\"> <s:Body> <x:FlickrRequest xmlns:x=\"urn:flickr\">"];
	
	//add method
	[soapMessage appendString:@"<method>\n"];
	[soapMessage appendString:@"flickr.photos.licenses.setLicense\n"];
	[soapMessage appendString:@"</method>\n"];
	
	//add api_key
	[soapMessage appendString:@"<api_key>\n"];
	[soapMessage appendString:[flickrController apiKey]];
	[soapMessage appendString:@"</api_key>\n"];
	
	//add auth_token
	[soapMessage appendString:@"<auth_token>\n"];
	[soapMessage appendString:[flickrController token]];
	[soapMessage appendString:@"</auth_token>\n"];
	
	//add photo id
	[soapMessage appendString:@"<photo_id>\n"];
	[soapMessage appendString:flickrID];
	[soapMessage appendString:@"</photo_id>\n"];
	
	//add license_id
	[soapMessage appendString:@"<license_id>\n"];
	[soapMessage appendString:@"4"];
	[soapMessage appendString:@"</license_id>\n"];
	
	//add signature
	[soapMessage appendString:@"<api_sig>\n"];
	[soapMessage appendString:[self generateSignatureForLicense]];
	[soapMessage appendString:@"</api_sig>\n"];
	
	[soapMessage appendString:@"</x:FlickrRequest> </s:Body> </s:Envelope>"];
	
	NSLog(soapMessage);
	
	//add the body to the post
	[tumblrPost setHTTPBody:[soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
	
	[tumblrPost addValue:[NSString stringWithFormat:@"%d",[soapMessage length]] forHTTPHeaderField:@"Content-length"];
	
	//send request, return YES if successful
	NSURLConnection *connection = [[[NSURLConnection alloc] initWithRequest:tumblrPost delegate:self] autorelease];
	if (!connection) {
		NSLog(@"Failed to submit license request");
	} else {
		NSLog(@"license Request submitted");
	}
	
}


- (NSString *)titleForUpload {
	if ([binomial isEqualToString:@""]) return common;
	else return binomial;
}

- (NSURL *)URLOfImageOnFlickr {
	NSString *URLString = [[NSString stringWithFormat:@"http://m.flickr.com/photos/%@/", [flickrController nsid]] stringByAppendingString:flickrID];
		
	return [NSURL URLWithString:URLString];
}

- (void)dealloc {
	[super dealloc];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog([error description]);
	[delegate imageDidFailToUploadToFlickr];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	NSLog(@"got response");
	
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	NSLog(@"received data");
	
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
	[parser setDelegate:self];
	[parser parse];
	[parser release];
	
	NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSLog(dataString);
	[dataString release];
	
}

- (id)delegate {
    return delegate;
}

- (void)setDelegate:(id)newDelegate {
    delegate = newDelegate;
}

@end

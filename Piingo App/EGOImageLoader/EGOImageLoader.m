//
//  EGOImageLoader.m
//  EGOImageLoading
//
//  Created by Shaun Harrison on 9/15/09.
//  Copyright 2009 enormego. All rights reserved.
//
//  This work is licensed under the Creative Commons GNU General Public License License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/GPL/2.0/
//  or send a letter to Creative Commons, 171 Second Street, Suite 300, San Francisco, California, 94105, USA.
//

#import "EGOImageLoader.h"
#import "EGOImageLoadConnection.h"
#import "EGOCache.h"

static EGOImageLoader* __imageLoader;

inline static NSString* keyForURL(NSURL* url) {
	return [NSString stringWithFormat:@"EGOImageLoader-%lu", (unsigned long)[[url description] hash]];
}

#define kImageNotificationLoaded(s) [@"kEGOImageLoaderNotificationLoaded-" stringByAppendingString:keyForURL(s)]
#define kImageNotificationLoadFailed(s) [@"kEGOImageLoaderNotificationLoadFailed-" stringByAppendingString:keyForURL(s)]

@implementation EGOImageLoader
@synthesize currentConnections=_currentConnections;

+ (EGOImageLoader*)sharedImageLoader {
	@synchronized(self) {
		if(!__imageLoader) {
			__imageLoader = [[[self class] alloc] init];
		}
	}
	
	return __imageLoader;
}

- (id)init {
	if((self = [super init])) {
		connectionsLock = [[NSLock alloc] init];
		currentConnections = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}

- (EGOImageLoadConnection*)loadingConnectionForURL:(NSURL*)aURL {
	EGOImageLoadConnection* connection = [[self.currentConnections objectForKey:aURL] retain];
	if(!connection) return nil;
	else return [connection autorelease];
}

- (void)cleanUpConnection:(EGOImageLoadConnection*)connection {
	if(!connection.imageURL) return;
	
	connection.delegate = nil;
	
	[connectionsLock lock];
	[currentConnections removeObjectForKey:connection.imageURL];
	self.currentConnections = [[currentConnections copy] autorelease];
	[connectionsLock unlock];	
}

- (BOOL)isLoadingImageURL:(NSURL*)aURL {
	return [self loadingConnectionForURL:aURL] ? YES : NO;
}

- (void)cancelLoadForURL:(NSURL*)aURL {
	EGOImageLoadConnection* connection = [self loadingConnectionForURL:aURL];
	[connection cancel];
	[self cleanUpConnection:connection];
}

- (void)loadImageForURL:(NSURL*)aURL observer:(id<EGOImageLoaderObserver>)observer {
	if(!aURL) return;
	
	if([observer respondsToSelector:@selector(imageLoaderDidLoad:)]) {
		[[NSNotificationCenter defaultCenter] addObserver:observer selector:@selector(imageLoaderDidLoad:) name:kImageNotificationLoaded(aURL) object:self];
	}
	
	if([observer respondsToSelector:@selector(imageLoaderDidFailToLoad:)]) {
		[[NSNotificationCenter defaultCenter] addObserver:observer selector:@selector(imageLoaderDidFailToLoad:) name:kImageNotificationLoadFailed(aURL) object:self];
	}
	
	if([self loadingConnectionForURL:aURL]) {
		return;
	}
	
	EGOImageLoadConnection* connection = [[EGOImageLoadConnection alloc] initWithImageURL:aURL delegate:self];

	[connectionsLock lock];
	[currentConnections setObject:connection forKey:aURL];
	self.currentConnections = [[currentConnections copy] autorelease];
	[connectionsLock unlock];

	[connection start];
	[connection release];
}

- (UIImage*)imageForURL:(NSURL*)aURL shouldLoadWithObserver:(id<EGOImageLoaderObserver>)observer {
	if(!aURL) return nil;
	
	UIImage* anImage = [[EGOCache currentCache] imageForKey:keyForURL(aURL)];
	
	if(anImage) {
		return anImage;
	} else {
		[self loadImageForURL:(NSURL*)aURL observer:observer];
		return nil;
	}
}

#pragma mark -
#pragma mark URL Connection delegate methods

-(void)connectionDidFinishLoading:(EGOImageLoadConnection *)connection {
	UIImage* anImage = [UIImage imageWithData:connection.responseData];
	
	if(!anImage) {
		NSError* error = [NSError errorWithDomain:[connection.imageURL host] code:406 userInfo:nil];
		NSNotification* notification = [NSNotification notificationWithName:kImageNotificationLoadFailed(connection.imageURL)
																	 object:self
																   userInfo:[NSDictionary dictionaryWithObjectsAndKeys:error,@"error",connection.imageURL,@"imageURL",nil]];
		
		[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:YES];
	} else {
		[[EGOCache currentCache] setData:connection.responseData forKey:keyForURL(connection.imageURL) withTimeoutInterval:604800];
		
		[currentConnections removeObjectForKey:connection.imageURL];
		self.currentConnections = [[currentConnections copy] autorelease];
		
		NSNotification* notification = [NSNotification notificationWithName:kImageNotificationLoaded(connection.imageURL)
																	 object:self
																   userInfo:[NSDictionary dictionaryWithObjectsAndKeys:anImage,@"image",connection.imageURL,@"imageURL",nil]];
		
		[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:YES];
	}

	[self cleanUpConnection:connection];
}

- (void)connection:(EGOImageLoadConnection *)connection didFailWithError:(NSError *)error {
	[currentConnections removeObjectForKey:connection.imageURL];
	self.currentConnections = [[currentConnections copy] autorelease];
	
	NSNotification* notification = [NSNotification notificationWithName:kImageNotificationLoadFailed(connection.imageURL)
																 object:self
															   userInfo:[NSDictionary dictionaryWithObjectsAndKeys:error,@"error",connection.imageURL,@"imageURL",nil]];
	
	[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:YES];

	[self cleanUpConnection:connection];
}

#pragma mark -

- (void)dealloc {
	self.currentConnections = nil;
	[currentConnections release];
	[connectionsLock release];
	[super dealloc];
}

@end
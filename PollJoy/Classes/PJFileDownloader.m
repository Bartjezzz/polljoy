//
//  PJFileDownloader.m
//  PolljoySDK
//
//  Copyright (c) 2014 polljoy limited. All rights reserved.
//

#import "PJFileDownloader.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PJDebugUtil.h"
#import "PJPollView.h"
#import "PolljoyCore.h"
#import "PJPollView.h"

@interface PJFileDownloader ()

@property (nonatomic, strong) NSMutableData *activeDownload;
@property (nonatomic, strong) NSURLConnection *imageConnection;
@property (nonatomic, strong) NSURL *tmpDirURL;
@property (nonatomic, strong) NSURL *cachedTempFilenameURL;

@end

@implementation PJFileDownloader
@synthesize urlString, localTempFilename;

- (void)startDownload
{
    // check file already cache
    NSString *hashFileName = [[self.urlString sha1] stringByAppendingString:@".mp3"];
    self.tmpDirURL = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
    self.cachedTempFilenameURL = [self.tmpDirURL URLByAppendingPathComponent:hashFileName] ;
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[self.cachedTempFilenameURL path]];
    if (fileExists) {
        util_Log(@"[%@ %@] using cached file: %@ / original url: %@", _PJ_CLASS, _PJ_METHOD, [self.cachedTempFilenameURL path], self.urlString);
        
        __block NSURL *fileURL = [self.tmpDirURL URLByAppendingPathComponent:localTempFilename];
        [[NSFileManager defaultManager] copyItemAtURL:self.cachedTempFilenameURL toURL:fileURL error:nil];
        // call our delegate and tell it that our icon is ready for display
        if (self.completionHandler)
            self.completionHandler(fileURL);
        
        return;  // no need to download
    }
    
    self.activeDownload = [NSMutableData data];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60];
    
    // alloc+init and start an NSURLConnection; release on completion/failure
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    self.imageConnection = conn;
}

- (void)cancelDownload
{
    [self.imageConnection cancel];
    self.imageConnection = nil;
    self.activeDownload = nil;
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // Clear the activeDownload property to allow later attempts
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
    
    if (self.completionHandler)
        self.completionHandler(nil);

}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // save to local file
    __block NSURL *fileURL = [self.tmpDirURL URLByAppendingPathComponent:localTempFilename];
    [self.activeDownload writeToURL:self.cachedTempFilenameURL atomically:YES];
    [self.activeDownload writeToURL:fileURL atomically:YES];
    
    util_Log(@"[%@ %@] saving cached file: %@ / original url: %@", _PJ_CLASS, _PJ_METHOD, [self.cachedTempFilenameURL absoluteString], self.urlString);
    
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
    
    // call our delegate and tell it that our icon is ready for display
    if (self.completionHandler)
        self.completionHandler(fileURL);
}

@end

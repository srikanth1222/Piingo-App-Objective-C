//
//  WebserviceMethods.m
//  Ping
//
//  Created by SHASHANK on 15/02/15.
//  Copyright (c) 2015 shashank. All rights reserved.
//

#import "WebserviceMethods.h"
#import <AFNetworking/AFNetworking.h>
#import <Reachability.h>

#define TimeOUtInterval   30.0f
@interface WebserviceMethods ()
{
//    UIBackgroundTaskIdentifier bgTask;
    BOOL isUploading;
}

@property (nonatomic, retain) NSString *successCallback;

@end
@implementation WebserviceMethods

+(id) sharedWebRequest
{
    static WebserviceMethods *sharedWebRequest = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedWebRequest = [[self alloc] init];
    });
    return sharedWebRequest;
}

-(void)getRequestWithParam:(NSString*)req andWithDelegate:(id) parent andCallbackMethod:(NSString *)callback
{
    DLog(@"Get URL.. %@", req);
    
    NSURL *reqURL = [NSURL URLWithString:[[NSString stringWithFormat:@"%@",req] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSError *error = nil;
    
    NSMutableURLRequest *getReq = [[NSMutableURLRequest alloc] initWithURL:reqURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:TimeOUtInterval];
    
    [NSURLConnection sendAsynchronousRequest:getReq queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        
        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        DLog(@"%@",responseString);
        
        if (error)
        {
            DLog(@"%@ %li %@",error,(long)[error code],[error localizedDescription]);
            
            UIAlertView *errorMessageAlert = [[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [errorMessageAlert show];
            
            //        [[iToast makeText:[error localizedDescription]] show];
            
            if (callback) {
                
                [parent performSelectorOnMainThread:NSSelectorFromString(callback) withObject:nil waitUntilDone:YES];
                
            }
            else if ([parent respondsToSelector:@selector(receivedResponse:)]) {
                
                [parent performSelectorOnMainThread:@selector(receivedResponse:) withObject:nil waitUntilDone:YES];
            }
            else {
                
            }
            
            
            return;
            
        }
        
        if (callback) {
            
            //        [parent performSelector:NSSelectorFromString(callback) withObject:[self parseData:data]];
            [parent performSelectorOnMainThread:NSSelectorFromString(callback) withObject:[self parseData:data] waitUntilDone:YES];
            
        }
        else if ([parent respondsToSelector:@selector(receivedResponse:)]) {
            
            [parent performSelectorOnMainThread:@selector(receivedResponse:) withObject:[self parseData:data] waitUntilDone:YES];
        }
        else {
            
        }

    }];
    
    
    
}

-(id)parseData:(NSData *)data{
    
    NSError *error = nil;
    
    //NSString *strDa = [data data]
    
    NSString *strFormat = [[NSString alloc]initWithBytes:[data bytes] length:[data length] encoding:NSASCIIStringEncoding];
    
    NSData *dataOther = [strFormat dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    id jsonData = [NSJSONSerialization JSONObjectWithData:dataOther options:NSJSONReadingMutableContainers error:&error];
    
    if (error != nil) {
        DLog(@"Error parsing JSON.");
        // return nil;
        NSDictionary *dic = @{@"message":@"Server Error",@"success":@"false"};
        return dic;
        
    }
    else {
        //        DLog(@"Array: %@", jsonData);
        return jsonData;
    }
    
}
-(id)sendSynchronousRequestForComponent:(NSString *) name methodName:(NSString *)methodname  type:(NSString *) type  parameters:(NSDictionary *) parameters{
    id results;
    
    NSMutableURLRequest *urlRequest = [self generateURLRequestForComponent2:name methodName:methodname type:type parameters:parameters];
    
        NSLog(@"Input parameters %@",[[NSString alloc] initWithData:urlRequest.HTTPBody encoding:NSUTF8StringEncoding]);
    isUploading = YES;
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest
                                          returningResponse:&response
                                                      error:&error];
    isUploading = NO;
    NSLog(@"Response Data :%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
 
    AppDelegate *appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];

    if (error == nil)
    {
        // Parse data here
        results = [self parseData:data];
        
    }
    else
    {
//        if(![methodname isEqualToString:@"redeem-voucher"])
//            [[iToast makeText:[error localizedDescription]] show];
        
         UIAlertView *errorMessageAlert = [[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
         [errorMessageAlert show];
        
//        else if ([parent respondsToSelector:@selector(receivedResponse:)]) {
//            
//            [parent performSelectorOnMainThread:@selector(receivedResponse:) withObject:nil waitUntilDone:YES];
//        }

    }
    
    // AppDelegate *appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    // [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
    
    return results;
}

-(void)sendAsynchronousRequestForComponent:(NSString *) name  methodName:(NSString *)methodname type:(NSString *) type   parameters:(NSDictionary *) parameters delegate:(id)del
{
    NSMutableURLRequest *urlRequest;
//    if ([methodname containsString:@"pushlatlong"])
    if ([methodname rangeOfString:@"pushlatlong"].location != NSNotFound)
        urlRequest = [self generateURLRequestForComponent3:name methodName:methodname type:type parameters:parameters];
//    else if ([name containsString:@"RegisterDevice"])
    else if ([methodname rangeOfString:@"RegisterDevice"].location != NSNotFound)
        urlRequest = [self generateURLRequestForComponent2:name methodName:methodname type:type parameters:parameters];
    else
        urlRequest = [self generateURLRequestForComponent:name methodName:methodname type:type parameters:parameters];

    currentConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self startImmediately:YES];
//    if ([name isEqual:@"venue"])
//        isUploading = NO;
//    else
//        isUploading =YES;
    delegate = del;
    
    //    [currentConnection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [currentConnection start];
}
-(NSMutableURLRequest *)generateURLRequestForComponent2:(NSString *)name  methodName:(NSString *)methodNeme type:(NSString *) type parameters:(NSDictionary *)param
{
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:param];
    
    NSString *urlString=[NSString stringWithFormat:@"%@%@%@?",BASE_URL,name,methodNeme];
    
    
    
    
    //    NSMutableURLRequest *postRequest = [[NSMutableURLRequest alloc] init];
    //	[postRequest setURL:reqURL];
    //	[postRequest setHTTPMethod:type];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    
    [request setHTTPMethod:type];
    
    if([[type uppercaseString] isEqualToString:@"POST"]){
        
        NSString *contentType = [NSString stringWithFormat:@"application/x-www-form-urlencoded"];
        [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
        
        NSMutableData *body = [NSMutableData data];
        
        
        for (int i=0; i<2; i++) {
            if([parameters valueForKey:@"profile"] || [parameters valueForKey:@"cover"])
            {
                NSString *key;
                if([parameters valueForKey:@"profile"])
                    key=@"profile";
                else
                    key =@"cover";
                UIImage *img=[parameters valueForKey:key];
                
                
                NSData *imageData =UIImageJPEGRepresentation(img,1.0);
                
                [body appendData:[[NSString stringWithFormat:@"Content-Disposition: application/x-www-form-urlencoded; name=\"%@\"; filename=\"%@%@.jpg\"",key,@"winter",key]  dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[@"Content-Type: image/jpeg" dataUsingEncoding:NSUTF8StringEncoding]];
                
                [body appendData:imageData];
                
                [parameters removeObjectForKey:key];
            }
        }
        
        
        NSArray *allDicKeys = [parameters allKeys];
        
            for (int i=0;i<[allDicKeys count];i++) {
                if(i)
                    urlString = [urlString stringByAppendingFormat:@"&%@=%@",[allDicKeys objectAtIndex:i],[param valueForKey:[allDicKeys objectAtIndex:i]]];
                else
                    urlString = [urlString stringByAppendingFormat:@"%@=%@",[allDicKeys objectAtIndex:i],[param valueForKey:[allDicKeys objectAtIndex:i]]];
            }
        
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
        
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        
        // setting the body of the post to the reqeust
        [request setHTTPBody:body];
        
        NSLog(@"\nrequest .. %@ \nInput parameters %@", request, [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding]);
    }else{
        
        
        NSArray *allDicKeys = [parameters allKeys];
        if([allDicKeys count])
            urlString = [urlString stringByAppendingString:@""];
        
        for (int i=0;i<[allDicKeys count];i++) {
            if(i)
                urlString = [urlString stringByAppendingFormat:@"&%@=%@",[allDicKeys objectAtIndex:i],[param valueForKey:[allDicKeys objectAtIndex:i]]];
            else
                urlString = [urlString stringByAppendingFormat:@"%@=%@",[allDicKeys objectAtIndex:i],[param valueForKey:[allDicKeys objectAtIndex:i]]];
        }
    }
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"url string:%@",urlString);
    
    NSURL * reqURL = [NSURL URLWithString:urlString];
    [request setURL:reqURL];
    
    return request;
    
}
-(NSMutableURLRequest *)generateURLRequestForComponent3:(NSString *)name  methodName:(NSString *)methodNeme type:(NSString *) type parameters:(NSDictionary *)param
{
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:param];
    
    NSString *urlString=[NSString stringWithFormat:@"%@/%@%@",BASE_TRACKING_URL,name,methodNeme];
    
    
    
    
    //    NSMutableURLRequest *postRequest = [[NSMutableURLRequest alloc] init];
    //	[postRequest setURL:reqURL];
    //	[postRequest setHTTPMethod:type];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    
    [request setHTTPMethod:type];
    
    if([[type uppercaseString] isEqualToString:@"POST"]){
        
        NSString *boundary = @"------------------------------78731b562e5a";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
        [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
        [request addValue:@"application/json" forHTTPHeaderField: @"Accept"];
        
        NSMutableData *body = [NSMutableData data];
        
        [ body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        for (int i=0; i<2; i++) {
            if([parameters valueForKey:@"profile"] || [parameters valueForKey:@"cover"])
            {
                NSString *key;
                if([parameters valueForKey:@"profile"])
                    key=@"profile";
                else
                    key =@"cover";
                UIImage *img=[parameters valueForKey:key];
                
                
                NSData *imageData =UIImageJPEGRepresentation(img,1.0);
                
                [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@%@.jpg\"\r\n",key,@"winter",key]  dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                
                [body appendData:imageData];
                
                [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                [parameters removeObjectForKey:key];
            }
        }
        
        
        NSArray *allDicKeys = [parameters allKeys];
        
        for (int i=0;i<[allDicKeys count];i++) {
            
            
            
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\";\r\n",[allDicKeys objectAtIndex:i]] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"\r\n%@",[parameters valueForKey:[allDicKeys objectAtIndex:i]]] dataUsingEncoding:NSUTF8StringEncoding]];
            if (!(i==[allDicKeys count]-1)) {
                [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                
            }
            else{
                [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                
            }
        }
        
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
        
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        
        // setting the body of the post to the reqeust
        [request setHTTPBody:body];
        
        NSLog(@"\nrequest .. %@ \nInput parameters %@", request, [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding]);
    }else{
        
        
        NSArray *allDicKeys = [parameters allKeys];
        if([allDicKeys count])
            urlString = [urlString stringByAppendingString:@"?"];
        
        for (int i=0;i<[allDicKeys count];i++) {
            if(i)
                urlString = [urlString stringByAppendingFormat:@"&&%@=%@",[allDicKeys objectAtIndex:i],[param valueForKey:[allDicKeys objectAtIndex:i]]];
            else
                urlString = [urlString stringByAppendingFormat:@"%@=%@",[allDicKeys objectAtIndex:i],[param valueForKey:[allDicKeys objectAtIndex:i]]];
        }
    }
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"url string:%@",urlString);
    
    NSURL * reqURL = [NSURL URLWithString:urlString];
    [request setURL:reqURL];
    
    return request;
    
}
-(NSMutableURLRequest *)generateURLRequestForComponent:(NSString *)name  methodName:(NSString *)methodNeme type:(NSString *) type parameters:(NSDictionary *)param
{
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:param];
    
    NSString *urlString=[NSString stringWithFormat:@"%@%@%@",BASE_URL,name,methodNeme];
    
    
    
    
    //    NSMutableURLRequest *postRequest = [[NSMutableURLRequest alloc] init];
    //	[postRequest setURL:reqURL];
    //	[postRequest setHTTPMethod:type];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    
    [request setHTTPMethod:type];
    
    if([[type uppercaseString] isEqualToString:@"POST"]){
        
        NSString *boundary = @"------------------------------78731b562e5a";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
        [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
        [request addValue:@"application/json" forHTTPHeaderField: @"Accept"];
        
        NSMutableData *body = [NSMutableData data];
        
        [ body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        for (int i=0; i<2; i++) {
            if([parameters valueForKey:@"profile"] || [parameters valueForKey:@"cover"])
            {
                NSString *key;
                if([parameters valueForKey:@"profile"])
                    key=@"profile";
                else
                    key =@"cover";
                UIImage *img=[parameters valueForKey:key];
                
                
                NSData *imageData =UIImageJPEGRepresentation(img,1.0);
                
                [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@%@.jpg\"\r\n",key,@"winter",key]  dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                
                [body appendData:imageData];
                
                [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                [parameters removeObjectForKey:key];
            }
        }
        
        
        NSArray *allDicKeys = [parameters allKeys];
        
        for (int i=0;i<[allDicKeys count];i++) {
            
            
            
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\";\r\n",[allDicKeys objectAtIndex:i]] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"\r\n%@",[parameters valueForKey:[allDicKeys objectAtIndex:i]]] dataUsingEncoding:NSUTF8StringEncoding]];
            if (!(i==[allDicKeys count]-1)) {
                [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                
            }
            else{
                [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                
            }
        }
        
        NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
        
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        
        // setting the body of the post to the reqeust
        [request setHTTPBody:body];
        
        NSLog(@"\nrequest .. %@ \nInput parameters %@", request, [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding]);
    }else{
        
        
        NSArray *allDicKeys = [parameters allKeys];
        if([allDicKeys count])
            urlString = [urlString stringByAppendingString:@"?"];
        
        for (int i=0;i<[allDicKeys count];i++) {
            if(i)
                urlString = [urlString stringByAppendingFormat:@"&&%@=%@",[allDicKeys objectAtIndex:i],[param valueForKey:[allDicKeys objectAtIndex:i]]];
            else
                urlString = [urlString stringByAppendingFormat:@"%@=%@",[allDicKeys objectAtIndex:i],[param valueForKey:[allDicKeys objectAtIndex:i]]];
        }
    }
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"url string:%@",urlString);
    
    NSURL * reqURL = [NSURL URLWithString:urlString];
    [request setURL:reqURL];
    
    return request;
    
}



+(void)sendRequestWithURLString:(NSString *)URLString requestMethod:(NSString *)method withDetailsDictionary:(NSDictionary *)detailsDictionary andResponseCallBack:(void(^)(NSURLResponse *response, NSError *error, id responseObj))apiResponse{
    
    // Allocate a reachability object
    Reachability* reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    DLog(@"API Method.. %@", URLString);
    
    if ([reach isReachable])
    {
        NSLog(@"REACHABLE!");
        
        NSMutableURLRequest *req1 = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:URLString] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:20];
        
        NSData *postData = [NSJSONSerialization dataWithJSONObject:detailsDictionary options:NSJSONWritingPrettyPrinted error:nil];
        
        [req1 setHTTPMethod:@"POST"];
        [req1 setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [req1 setHTTPBody:postData];
        
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfig.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
        sessionConfig.URLCache = nil;
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
        
        [[session dataTaskWithRequest:req1 completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                if (!error) {
                    
                    id responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                    
                    DLog(@"API Response.. %@", responseObject);
                    
                    apiResponse(response, error, responseObject);
                    
                } else {
                    //NSLog(@"Error: %@, %@, %@", error, response, responseObject);
                }
            }];
            
        }] resume];
        
        
        //        NSString *postString = @"";
        //        if([method isEqualToString:@"POST"]) {
        //            for (NSString *key in [detailsDictionary allKeys]) {
        //                postString = [NSString stringWithFormat:@"%@%@=%@&",postString,key,[detailsDictionary objectForKey:key]];
        //            }
        //
        //            if (postString.length) {
        //                postString = [postString stringByReplacingCharactersInRange:NSMakeRange([postString length]-1, 1)  withString:@""];
        //            }
        //            else {
        //                postString = nil;
        //                strUrl = [strUrl stringByReplacingOccurrencesOfString:@"?" withString:@""];
        //            }
        //        }
        //
        //        NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        //        [mutableRequest setHTTPMethod:method];
        //        [mutableRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
        //
        //        NSData *data = [postString dataUsingEncoding:NSUTF8StringEncoding];
        //        if(data) {
        //            [mutableRequest setHTTPBody:data];
        //            [mutableRequest setValue:[NSString stringWithFormat:@"%lu", [data length]] forHTTPHeaderField:@"Content-Length"];
        //        }
        //
        //        DLog(@"url request.. %@", mutableRequest);
        //        [NSURLConnection sendAsynchronousRequest:mutableRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        //
        //            NSString *strFormat = [[NSString alloc]initWithBytes:[data bytes] length:[data length] encoding:NSASCIIStringEncoding];
        //            //strFormat = [strFormat stringByReplacingOccurrencesOfString:@"\"\"" withString:@"\""];
        //
        //            NSData *dataOther = [strFormat dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        //
        //            NSError *jsonError = nil;
        //
        //            id respObj = nil;
        //            if(dataOther)
        //                respObj = [NSJSONSerialization JSONObjectWithData:dataOther options:NSJSONReadingMutableContainers error:&jsonError];
        //
        //            DLog(@"API Response.. %@", respObj);
        //
        //            if (!connectionError)
        //            {
        //                connectionError = jsonError;
        //            }
        //            //        else
        //            //        {
        //            //                            AppDelegate *appDel = [[PiingHandler sharedHandler] appDel];
        //            //            [appDel showAlertWithMessage:[connectionError localizedDescription] andTitle:@"Error" andBtnTitle:@"OK"];
        //            //            [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
        //            //
        //            //            return;
        //            //        }
        //
        //            apiResponse(response, connectionError, respObj);
        //
        //        }];
        
    }
    else
    {
        
        AppDelegate *appDel = (AppDelegate *) [[UIApplication sharedApplication]delegate];
        [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
        
        //apiResponse(nil, nil, nil);
        
        [appDel showAlertWithMessage:@"The Internet connection appears to be offline." andTitle:@"" andBtnTitle:@"OK"];
    }
    
}

+(void)sendImageRequestWithURLString:(NSString *)urlString requestMethod:(NSString *)method withDetailsDictionary:(NSDictionary *)detailsDictionary withImageDict:(NSDictionary *)dict andResponseCallBack:(void(^)(NSURLResponse *response, NSError *error, id responseObj))apiResponse;
{
    NSString *postString = @"";
    
    NSString *imgString = @"";
    
    if([method isEqualToString:@"POST"]) {
        for (NSString *key in [detailsDictionary allKeys]) {
            postString = [NSString stringWithFormat:@"%@%@=%@&",postString,key,[detailsDictionary objectForKey:key]];
        }
        
        if (postString.length) {
            postString = [postString stringByReplacingCharactersInRange:NSMakeRange([postString length]-1, 1)  withString:@""];
        }
        else {
            postString = nil;
            urlString = [urlString stringByReplacingOccurrencesOfString:@"?" withString:@""];
        }
        
        
        for (NSString *key in [dict allKeys]) {
            imgString = [NSString stringWithFormat:@"%@%@=%@&",imgString,key,[dict objectForKey:key]];
        }
        
        if (imgString.length) {
            imgString = [imgString stringByReplacingCharactersInRange:NSMakeRange([imgString length]-1, 1)  withString:@""];
        }
        else {
            imgString = nil;
            urlString = [urlString stringByReplacingOccurrencesOfString:@"?" withString:@""];
        }
    }
    
    NSString *str = [urlString stringByAppendingFormat:@"%@", postString];
    
    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    [mutableRequest setHTTPMethod:method];
    [mutableRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    
    NSData *data = [imgString dataUsingEncoding:NSUTF8StringEncoding];
    if(data) {
        [mutableRequest setHTTPBody:data];
        
        [mutableRequest setValue:[NSString stringWithFormat:@"%lu", [data length]] forHTTPHeaderField:@"Content-Length"];
    }
    
    DLog(@"url request.. %@", mutableRequest);
    [NSURLConnection sendAsynchronousRequest:mutableRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        
        NSError *jsonError = nil;
        
        NSString *strFormat = [[NSString alloc]initWithBytes:[data bytes] length:[data length] encoding:NSASCIIStringEncoding];
        
        NSData *dataOther = [strFormat dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        
        id respObj = nil;
        if(dataOther)
            respObj = [NSJSONSerialization JSONObjectWithData:dataOther options:NSJSONReadingAllowFragments error:&jsonError];
        
        DLog(@"API Response.. %@", respObj);
        
        if (!connectionError)
            connectionError = jsonError;
        
        apiResponse(response, connectionError, respObj);
        
    }];
    
}


#pragma mark Connection delegate methods
-(void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    responseData = [[NSMutableData alloc] initWithCapacity:0];
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
}

-(void) connectionDidFinishLoading:(NSURLConnection *)connection {
    
    if (!delegate)
    {
        return;
    }
//    AppDelegate *appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];

//    isUploading = NO;
    if ([delegate respondsToSelector:NSSelectorFromString(self.successCallback)]) {
        [delegate performSelector:NSSelectorFromString(self.successCallback) withObject:[self parseData:responseData]];
    }
    else if([delegate respondsToSelector:@selector(receivedResponse:)])
        [delegate receivedResponse:[self parseData:responseData]];
   
    responseData = nil;
    
}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
//    isUploading = NO;
    AppDelegate *appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
    
        UIAlertView *errorMessageAlert = [[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [errorMessageAlert show];
//    [[iToast makeText:[error localizedDescription]] show];
    
    responseData = nil;
    
    if ([delegate respondsToSelector:NSSelectorFromString(self.successCallback)]) {
        [delegate performSelector:NSSelectorFromString(self.successCallback) withObject:nil];
    }
    else if([delegate respondsToSelector:@selector(receivedResponse:)])
        [delegate receivedResponse:nil];
    
}

#pragma mark Some other Methods
-(NSMutableAttributedString *) getAttributedStringWithSpacing:(NSString *) string andWithColor:(UIColor *) selectedColor andFont:(UIFont *) selectedFont
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",string]];
    
    @try {
        [attributedString addAttribute:NSKernAttributeName
                                 value:@(3)
                                 range:NSMakeRange(0, [string length])];
        
        //    [attributedString addAttribute:NSFontAttributeName
        //                             value:selectedFont
        //                             range:NSMakeRange(0, [string length])];
        
        [attributedString addAttribute:NSForegroundColorAttributeName
                                 value:selectedColor
                                 range:NSMakeRange(0, [string length])];
        
        [attributedString addAttribute:NSFontAttributeName
                                 value:selectedFont
                                 range:NSMakeRange(0, [string length])];
        
    }
    @catch (NSException *exception) {
        DLog(@"Exception %@",[exception description]);
    }
    @finally {
        return attributedString;
        
    }
    
    //https://marvelapp.com/53b134#7091830
    
    //    return attributedString;
}


@end

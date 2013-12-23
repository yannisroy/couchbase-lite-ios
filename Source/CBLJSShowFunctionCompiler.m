//
//  CBLJSShowFunctionCompiler.m
//  CouchbaseLite
//
//  Created by Igor Evsukov on 7/27/13.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
//  except in compliance with the License. You may obtain a copy of the License at
//    http://www.apache.org/licenses/LICENSE-2.0
//  Unless required by applicable law or agreed to in writing, software distributed under the
//  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
//  either express or implied. See the License for the specific language governing permissions
//  and limitations under the License.
//

#import "CBLJSShowFunctionCompiler.h"
#import <CouchbaseLite/CBLRevision.h>
#import <JavaScriptCore/JavaScript.h>
#import <JavaScriptCore/JSStringRefCF.h>

/* NOTE: JavaScriptCore is not a public system framework on iOS, so you'll need to link your iOS app
 with your own copy of it. See <https://github.com/phoboslab/JavaScriptCore-iOS>. */

/* NOTE: This source file requires ARC. */

@implementation CBLJSShowFunctionCompiler

- (CBLShowFunctionBlock) compileShowFunction: (NSString*)showSource language: (NSString*)language {
    if (![language isEqualToString: @"javascript"])
        return nil;
    
    // Compile the function:
    CBLJSFunction* fn = [[CBLJSFunction alloc] initWithCompiler: self
                                                     sourceCode: showSource
                                                     paramNames: @[@"doc", @"req"]];
    if (!fn)
        return nil;
    
    // Return the CBLMapBlock; the code inside will be called when CouchbaseLite wants to run the map fn:
    JSContextRef ctx = self.context;
    CBLShowFunctionBlock block = ^CBLShowFunctionResult*(NSDictionary *revision, NSDictionary *params){
        CBLShowFunctionResult* result = [CBLShowFunctionResult new];
        
        JSValueRef exception = NULL;
        JSValueRef fnRes = [fn callWithParams:@[revision, params] exception:&exception];
        id obj = ValueToID(ctx, fnRes);
        if (exception) {
            NSMutableDictionary *body = [NSMutableDictionary dictionary];

            JSStringRef error = JSValueToStringCopy(ctx, exception, NULL);
            CFStringRef cfError = error ? JSStringCopyCFString(NULL, error) : NULL;
            [body setValue:(__bridge id)cfError forKey:@"error"];
            CFRelease(cfError);
            
            [body setValue:obj forKey:@"result"];
            result.body = body;
            result.status = kCBLStatusException;
        } else {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                NSDictionary* resDict = (NSDictionary*)obj;
                result.body = resDict[@"body"];
                
                if (resDict[@"status"])
                    result.status = [resDict[@"status"] unsignedIntegerValue];
                
                if ([resDict[@"headers"] isKindOfClass:[NSDictionary class]])
                    result.headers = resDict[@"headers"];
            } else if ([obj isKindOfClass:[NSString class]]) {
                result.body = obj;
            }
        }
        
        return result;
    };
    return [block copy];
}


@end

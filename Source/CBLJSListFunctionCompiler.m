//
//  CBLJSListFunctionCompiler.m
//  CouchbaseLite
//
//  Created by Igor Evsukov on 8/4/13.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
//  except in compliance with the License. You may obtain a copy of the License at
//    http://www.apache.org/licenses/LICENSE-2.0
//  Unless required by applicable law or agreed to in writing, software distributed under the
//  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
//  either express or implied. See the License for the specific language governing permissions
//  and limitations under the License.
//

#import "CBLJSListFunctionCompiler.h"
#import <CouchbaseLite/CBLQuery.h>
#import <JavaScriptCore/JavaScript.h>
#import <JavaScriptCore/JSStringRefCF.h>

/* NOTE: JavaScriptCore is not a public system framework on iOS, so you'll need to link your iOS app
 with your own copy of it. See <https://github.com/phoboslab/JavaScriptCore-iOS>. */

/* NOTE: This source file requires ARC. */

@implementation CBLJSListFunctionCompiler

// This is a kludge that remembers the emit block passed to the currently active map block.
// It's valid only while a map block is running its JavaScript function.
static
#if !TARGET_OS_IPHONE   /* iOS doesn't support __thread ? */
__thread
#endif
__unsafe_unretained CBLListFunctionGetRowBlock sCurrentGetRowBlock;

// This is the body of the JavaScript "getRow()" function.
static JSValueRef GetRowCallback(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                 size_t argumentCount, const JSValueRef arguments[],
                                 JSValueRef* exception)
{
    CBLQueryRow *row = sCurrentGetRowBlock();
    return IDToValue(ctx, [row asJSONDictionary]);
}

- (instancetype) init {
    self = [super init];
    if (self) {
        JSGlobalContextRef context = self.context;
        // Install the "getRow" function in the context's namespace:
        JSStringRef name = JSStringCreateWithCFString(CFSTR("getRow"));
        JSObjectRef fn = JSObjectMakeFunctionWithCallback(context, name, &GetRowCallback);
        JSObjectSetProperty(context, JSContextGetGlobalObject(context),
                            name, fn,
                            kJSPropertyAttributeReadOnly | kJSPropertyAttributeDontDelete,
                            NULL);
        JSStringRelease(name);
    }
    return self;
}


- (CBLListFunctionBlock) compileListFunction: (NSString*)listSource language: (NSString*)language {
    if (![language isEqualToString: @"javascript"])
        return nil;
    
    // Compile the function:
    CBLJSFunction* fn = [[CBLJSFunction alloc] initWithCompiler: self
                                                     sourceCode: listSource
                                                     paramNames: @[@"head", @"req"]];
    if (!fn)
        return nil;
    
    JSContextRef ctx = self.context;
    CBLListFunctionBlock block = ^CBLListFunctionResult*(NSDictionary *head, NSDictionary *params, CBLListFunctionGetRowBlock getRowBlock) {
        CBLListFunctionResult* result = [CBLListFunctionResult new];
        
        // using the same trick for the getRow function as for the emit in view
        // using global variable isn't the best idea, there should be a better
        // way of doing it
        sCurrentGetRowBlock = getRowBlock;
        JSValueRef exception = NULL;
        JSValueRef fnRes = [fn callWithParams:@[head, params] exception:&exception];
        sCurrentGetRowBlock = nil;
        
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

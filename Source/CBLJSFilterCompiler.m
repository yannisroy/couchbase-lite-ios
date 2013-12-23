//
//  CBLJSFilterCompiler.m
//  CouchbaseLite
//
//  Created by Igor Evsukov on 7/27/13.
//
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
//  except in compliance with the License. You may obtain a copy of the License at
//    http://www.apache.org/licenses/LICENSE-2.0
//  Unless required by applicable law or agreed to in writing, software distributed under the
//  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
//  either express or implied. See the License for the specific language governing permissions
//  and limitations under the License.
//

#import "CBLJSFilterCompiler.h"
#import <CouchbaseLite/CBLRevision.h>
#import <JavaScriptCore/JavaScript.h>
#import <JavaScriptCore/JSStringRefCF.h>

/* NOTE: JavaScriptCore is not a public system framework on iOS, so you'll need to link your iOS app
 with your own copy of it. See <https://github.com/phoboslab/JavaScriptCore-iOS>. */

/* NOTE: This source file requires ARC. */

@implementation CBLJSFilterCompiler

- (CBLFilterBlock) compileFilterFunction: (NSString*)filterSource language: (NSString*)language {
    if (![language isEqualToString: @"javascript"])
        return nil;
    
    // Compile the function:
    CBLJSFunction* fn = [[CBLJSFunction alloc] initWithCompiler: self
                                                     sourceCode: filterSource
                                                     paramNames: @[@"doc", @"req"]];
    if (!fn)
        return nil;
    
    // Return the CBLMapBlock; the code inside will be called when CouchbaseLite wants to run the map fn:
    JSContextRef ctx = self.context;
    CBLFilterBlock block = ^BOOL(CBLRevision* revision, NSDictionary* params) {
        return JSValueToBoolean(ctx, [fn call: revision.properties, params]);
    };
    return [block copy];
}

@end

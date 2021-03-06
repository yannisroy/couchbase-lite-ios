//
//  CBLShowFunction+Internal.h
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


#import "CBLShowFunction.h"
#import "CBLDatabase+Internal.h"
#import "CBLShowFunction.h"


@interface CBLShowFunction ()

- (instancetype) initWithDatabase: (CBLDatabase*)db name: (NSString*)name;

@end

@interface CBLShowFunction (Internal)

/** Compiles a view (using the registered CBLShowFunctionCompiler) from the properties found in a CouchDB-style design document. */
- (BOOL) compileFromSource: (NSString*)showSource
                  language: (NSString*)language
                  userInfo: (NSDictionary*)userInfo;

@end

//
//  CBLFunctionResult.h
//  CouchbaseLite
//
//  Created by Igor Evsukov on 12/26/13.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
//  except in compliance with the License. You may obtain a copy of the License at
//    http://www.apache.org/licenses/LICENSE-2.0
//  Unless required by applicable law or agreed to in writing, software distributed under the
//  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
//  either express or implied. See the License for the specific language governing permissions
//  and limitations under the License.
//

#import <Foundation/Foundation.h>
#import "CBLStatus.h"

/** Represents "Response object"(http://docs.couchdb.org/en/latest/json-structure.html#response-object) - show/list function result */
@interface CBLFunctionResult : NSObject

@property (readwrite, nonatomic) CBLStatus status;
@property (strong, nonatomic) NSDictionary* headers;
@property (strong, nonatomic) id body;

/** creates new object from JS func result, acts smartly depending if it's a string, array or an object */
- (id) initWithResultObject: (id)object;

@end

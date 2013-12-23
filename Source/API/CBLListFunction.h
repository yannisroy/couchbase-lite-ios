//
//  CBLListFunction.h
//  CouchbaseLite
//
//  Created by Igor Evsukov on 7/28/13.
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
@class CBLDatabase, CBLQueryRow, CBLQueryEnumerator;

#pragma mark - LIST FUNCTION RESULT
/** Since list function is really designed to work over HTTP, the result includes HTTP status code, headers and body.
 body can be string and any JSON serializable object */
// TODO: investigate if we really need two different classes for show and list functions
@interface CBLListFunctionResult : NSObject

@property (readwrite) CBLStatus status;
@property (strong) NSDictionary *headers;
@property (strong) id body;

@end

#pragma mark - BLOCK DEFINITIONS
typedef CBLQueryRow* (^CBLListFunctionGetRowBlock)();

typedef CBLListFunctionResult* (^CBLListFunctionBlock)(NSDictionary *head, NSDictionary *params, CBLListFunctionGetRowBlock getRowBlock);

#define LISTBLOCK(BLOCK) ^CBLListFunctionResult(NSDictionary *head, NSDictionary *params, CBLListFunctionGetRowBlock getRowBlock){BLOCK}

#pragma mark - COMPILER PROTOCOL
/**  An external object that knows how to map source code of some sort into executable functions. Similar to the CBLViewCompiler */
@protocol CBLListFunctionCompiler <NSObject>
- (CBLListFunctionBlock) compileListFunction: (NSString*)showSource language: (NSString*)language;
@end

#pragma mark - LIST FUNCTION
/** A "list function" in a CouchbaseLite database -- essentially a stored function used to modify view output.
 List functions doesn't make much sense to use in native code, but very useful when declared in design document. */
@interface CBLListFunction : NSObject
{
    @private
    CBLDatabase* __weak _db;
    NSString *_name;

}

/** The database that owns this show function. */
@property (readonly) CBLDatabase* database;

/** The name of the show function.
 In case of JS function it will be ddoc/showfuncname */
@property (readonly) NSString* name;

/** The block that controls how view output it gets changed */
@property (readwrite) CBLListFunctionBlock listFunctionBlock;

- (CBLListFunctionResult*) runWithQueryEnumenator: (CBLQueryEnumerator*)queryEnumenator head: (NSDictionary*)head params: (NSDictionary*)params;

/**
 * @rows array for CBLQueryRow objects
 */
- (CBLListFunctionResult*) runWithRows: (NSArray*)rows head: (NSDictionary*)head params: (NSDictionary*)params;

/** Registers an object that can compile map/reduce functions from source code. */
+ (void) setCompiler: (id<CBLListFunctionCompiler>)compiler;

/** The registered object, if any, that can compile map/reduce functions from source code. */
+ (id<CBLListFunctionCompiler>) compiler;

@end

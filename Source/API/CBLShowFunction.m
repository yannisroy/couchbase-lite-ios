//
//  CBLShowFunction.m
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
#import "CBLShowFunction+Internal.h"
#import "CBL_Shared.h"
#import "CBLRevision.h"

#pragma mark - SHOW FUNCTION RESULT
@implementation CBLShowFunctionResult

@synthesize status = _status;
@synthesize headers = _headers;
@synthesize body = _body;

- (instancetype)init {
    self = [super init];
    if (self) {
        _status = kCBLStatusOK;
    }
    return self;
}

- (NSString*) description {
    return [NSString stringWithFormat:@"<%@: %p, %@ %@, %@ >",
            NSStringFromClass(self.class),self,
            [NSNumber numberWithInteger:_status], _headers, _body];
}

@end


#pragma mark - SHOW FUNCTION
@implementation CBLShowFunction

- (instancetype) initWithDatabase: (CBLDatabase*)db name: (NSString*)name {
    Assert(db);
    Assert(name.length);
    self = [super init];
    if (self) {
        _db = db;
        _name = [name copy];
    }
    return self;
}

#pragma mark properties
@synthesize name=_name;

- (CBLDatabase*) database {
    return _db;
}

@dynamic showFunctionBlock;
- (CBLShowFunctionBlock) showFunctionBlock {
    CBLDatabase *db = _db;
    return [db.shared valueForType: @"showfunc" name: _name inDatabaseNamed: db.name];
}

- (void)setShowFunctionBlock: (CBLShowFunctionBlock)showFunctionBlock {
    Assert(showFunctionBlock);
    CBLDatabase *db = _db;
    [db.shared setValue: [showFunctionBlock copy]
                 forType: @"showfunc" name: _name inDatabaseNamed: db.name];
}

#pragma mark invoking show function
- (CBLShowFunctionResult*) runWithRevision: (CBLRevision *)revision params: (NSDictionary *)params {
    NSDictionary *properties = revision.properties;
    return [self runWithRevisionProperties:properties params:params];
}

- (CBLShowFunctionResult*)runWithRevisionProperties: (NSDictionary *)revisionProperties params: (NSDictionary *)params {
    CBLShowFunctionResult* result = self.showFunctionBlock(revisionProperties, params);
    return result;
}

#pragma mark CBLShowFunctionCompiler
static id<CBLShowFunctionCompiler> sCompiler;
+ (void) setCompiler: (id<CBLShowFunctionCompiler>)compiler {
    sCompiler = compiler;
}

+ (id<CBLShowFunctionCompiler>) compiler {
    return sCompiler;
}

@end

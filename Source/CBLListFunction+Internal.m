//
//  CBLListFunction+Internal.m
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

#import "CBLListFunction+Internal.h"

@implementation CBLListFunction (Internal)

- (BOOL) compileFromSource: (NSString*)listSource
                  language: (NSString*)language
{
    if (!language)
        language = @"javascript";
    
    CBLListFunctionBlock listFunctionBlock = [[CBLListFunction compiler] compileListFunction: listSource language: language];
    if (!listFunctionBlock) {
        Warn(@"List function %@ has unknown source function: %@", _name, listSource);
        return NO;
    }
    
    self.listFunctionBlock = listFunctionBlock;
    return YES;
}


@end

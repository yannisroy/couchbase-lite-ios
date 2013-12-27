//
//  CBLFunctionResult.m
//  CouchbaseLite
//
//  Created by Igor Evsukov on 12/26/13.
//
//

#import "CBLFunctionResult.h"

@implementation CBLFunctionResult

#pragma mark init / dealloc
- (instancetype) initWithResultObject: (id)object {
    self = [super init];
    if (self) {
        _status = kCBLStatusOK;
        _headers = @{};
        
        if ([object isKindOfClass:[NSDictionary class]]) {
            id code = object[@"code"];
            if ([code respondsToSelector:@selector(unsignedIntegerValue)])
                _status = (CBLStatus)[code unsignedIntegerValue];
            
            id headers = object[@"headers"];
            if ([headers isKindOfClass:[NSDictionary class]])
                _headers = headers;
            
            id body = object[@"body"];
            if ([body isKindOfClass:[NSString class]]) {
                _body = body;
                
                if (!_headers || !_headers[@"Content-Type"]) {
                    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithDictionary:_headers];
                    headers[@"Content-Type"] = @"text/html; charset=utf-8";
                    _headers = [headers copy];
                }
            }
            
            id json = object[@"json"];
            if ([NSJSONSerialization isValidJSONObject:json]) {
                _body = json;
                
                if (!_headers || !_headers[@"Content-Type"]) {
                    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithDictionary:_headers];
                    headers[@"Content-Type"] = @"application/json";
                    _headers = [headers copy];
                }
            }
            
            // TODO: parse base64 and stop properties
        } else if ([object isKindOfClass:[NSString class]]) {
            [self appendChunkToBody:object];
        }
    }
    return self;
}

#pragma mark helpers
- (BOOL) appendChunkToBody: (NSString*)chunk {
    if (!chunk || ![chunk isKindOfClass:[NSString class]])
        return NO;
    
    if (!_body || ![_body isKindOfClass:[NSMutableString class]]) {
        if ([_body isKindOfClass:[NSString class]])
            _body = [NSMutableString stringWithString:_body];
        else
            _body = [NSMutableString new];
    }
    
    [_body appendString:chunk];
    return YES;
}

- (NSString*) description {
    return [NSString stringWithFormat:@"<%@: %p, %@ %@, %@ >",
            NSStringFromClass(self.class),self,
            [NSNumber numberWithInteger:_status], _headers, _body];
}

#pragma mark properties
@synthesize status = _status;
@synthesize headers = _headers;
@synthesize body = _body;

@end

//
//  UnchangeableURLCache.m
//  Maishoku
//
//  Created by Jonathan Sweemer on 3/26/12.
//  Copyright (c) 2012 Dynaptico LLC. All rights reserved.
//

#import "UnchangeableURLCache.h"

@implementation UnchangeableURLCache

- (void)setMemoryCapacity:(NSUInteger)memoryCapacity;
{
    if (memoryCapacity > 0) {
        [super setMemoryCapacity:memoryCapacity];
    }
}

- (void)storeCachedResponse:(NSCachedURLResponse *)cachedResponse forRequest:(NSURLRequest *)request
{
    if ([cachedResponse.response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *r = (NSHTTPURLResponse *)cachedResponse.response;
        if (r.statusCode == 200) {
            [super storeCachedResponse:cachedResponse forRequest:request];
        }
    }
}

@end

//
//  DataModel+Helper.m
//  Arendator
//
//  Created by Grig Uskov on 14/9/13.
//  Copyright (c) 2013 Yury Nechaev. All rights reserved.
//

#import "DataModel+Helper.h"
#import "DataModel.h"
#import "Search.h"
#import "SearchResult.h"

@implementation SearchResult (Helper)

+ (SearchResult *)newInstanceForSearch:(Search *)parent {
    SearchResult *result = (SearchResult *)[DataModel createObjectOfClass:[SearchResult class]];
    if (result) {
        result.uid = generateGUID();
        result.search = parent;
    }
    return result;
}

@end


// ---------------------------------------------------------- //
@implementation Search (Helper)

+ (Search *)newInstance {
    Search *result = (Search *)[DataModel createObjectOfClass:[SearchResult class]];
    if (result) {
        result.uid = generateGUID();
        result.time = [NSDate date];
    }
    return result;
}

@end
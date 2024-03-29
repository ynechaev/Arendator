//
//  DataModel+Helper.m
//  Arendator
//
//  Created by Grig Uskov on 14/9/13.
//  Copyright (c) 2013 Yury Nechaev. All rights reserved.
//

#import "DataModel+Helper.h"
#import "Search.h"
#import "SearchResult.h"
#import <MagicalRecord/CoreData+MagicalRecord.h>

static NSString *generateGUID() {
    CFUUIDRef uuidObj = CFUUIDCreate(nil);
    NSString *uuidString = (__bridge NSString*)CFUUIDCreateString(nil, uuidObj);
    CFRelease(uuidObj);
    return uuidString;
}


static NSString *formatBabki(NSNumber *value) {
    float val = roundf(value.integerValue / 500) / 2;
    NSString *result = [NSString stringWithFormat:@"%.1f", val];
    return [[result stringByReplacingOccurrencesOfString:@".0" withString:@""] stringByReplacingOccurrencesOfString:@",0" withString:@""];
}



@implementation SearchResult (Helper)

- (NSString *)humanReadableAddress {
    NSString *result = !!self.street ? self.street : @"";
    if (self.house)
        result = [result stringByAppendingFormat:@", %@", self.house];
    return result;
}


+ (SearchResult *)newInstanceForSearch:(Search *)parent {
    SearchResult *result = [SearchResult createEntity];
    if (result) {
        result.uid = generateGUID();
        result.search = parent;
    }
    return result;
}


- (NSString *)humanReadablePrice {
    NSString *priceFMT = self.priceCurrency.intValue == 2 ? @"priceExactFMT1KRUB" : (self.priceCurrency.intValue == 0 ? @"priceExactFMT1USD" : @"priceExactFMT1EUR");
    NSString *price = self.priceCurrency.intValue == 2 ? formatBabki(self.price) : [NSString stringWithFormat:@"%i", self.price.integerValue];
    NSString *priceTypeFMT = self.priceType.intValue == 0 ? @"pricePerMonth" : @"pricePerDay";
    return [NSString stringWithFormat:NSLocalizedString(priceTypeFMT, @""), [NSString stringWithFormat:NSLocalizedString(priceFMT, @""), price]];
}


+ (SearchResult *)randomTestInstanceForSearch:(Search *)parent {
    SearchResult *result = [SearchResult newInstanceForSearch:parent];
    
    result.distanceFromMetro = @"5 минут пешком";
    result.flor = [NSNumber numberWithInt:1 + arc4random() % 9];
    result.florTotal = [NSNumber numberWithInt:result.flor.intValue + 2];
    result.house = @"д. 4";
    result.id = @"1234534";
    result.info = @"A lot of text here...";
    result.metroId = [NSNumber numberWithInt:1 + arc4random() % 30];
    result.options = @"телефон,телевизор";
    result.phones = @"+7 911 123-45-67,+7 911 555-66-77";
    result.price = [NSNumber numberWithInt:10000 + arc4random() % 40000];
    result.priceType = @1;
    result.requireDeposit = @YES;
    result.requireExtraMonth = @YES;
    result.rooms = [NSNumber numberWithInt:1 + arc4random() % 4];
    result.street = @"Энгельса";
    
    return result;
}


@end


// ---------------------------------------------------------- //
@implementation Search (Helper)

- (NSString *)roomsAsString {
    int from = !!self.roomFrom ? self.roomFrom.integerValue : 1;
    int to = !!self.roomTo ? self.roomTo.integerValue : 6;
    NSMutableArray *result = [NSMutableArray array];
    for (int i = from; i <= to; i++)
        [result addObject:[NSNumber numberWithInt:i]];
    return [result componentsJoinedByString:@","];
}


+ (Search *)newInstance {
    Search *result = [Search createEntity];
    if (result) {
        result.uid = generateGUID();
        result.time = [NSDate date];
        result.cityId = @10;
    }
    return result;
}


- (Boolean)metroStationChecked:(NSInteger)stationId {
    NSArray *stations = [self.metroIdStr componentsSeparatedByString:@","];
    for (NSString *station in stations)
        if ([station isEqualToString:[NSString stringWithFormat:@"%i", stationId]])
            return YES;
    return NO;
}


- (void)checkMetroStation:(NSInteger)stationId check:(Boolean)value {
    NSMutableArray *stations = [NSMutableArray arrayWithArray:[self.metroIdStr componentsSeparatedByString:@","]];
    [stations removeObject:[NSString stringWithFormat:@"%i", stationId]];
    if (value)
        [stations addObject:[NSString stringWithFormat:@"%i", stationId]];
    self.metroIdStr = [stations componentsJoinedByString:@","];
}


- (NSString *)humanReadablePriceRange {
    if (!self.priceFrom && !self.priceTo)
        return NSLocalizedString(@"rangeDoesNotMatter", @"");
    if (!!self.priceFrom && !!self.priceTo) {
        if (self.priceFrom.intValue == self.priceTo.intValue)
            return [NSString stringWithFormat:NSLocalizedString(@"priceExactFMT1KRUB", @""), formatBabki(self.priceFrom)];
        return [NSString stringWithFormat:NSLocalizedString(@"priceFromToFMT", @""), formatBabki(self.priceFrom), formatBabki(self.priceTo)];
    }
    if (!!self.priceFrom)
        return [NSString stringWithFormat:NSLocalizedString(@"priceFromFMT", @""), formatBabki(self.priceFrom)];
    if (!!self.priceTo)
        return [NSString stringWithFormat:NSLocalizedString(@"priceToFMT", @""), formatBabki(self.priceTo)];
    return @"???";
}


- (NSString *)humanReadableRoomRange {
    if (!self.roomFrom && !self.roomTo)
        return NSLocalizedString(@"rangeDoesNotMatter", @"");
    if (!!self.roomFrom && !!self.roomTo) {
        if (self.roomFrom.integerValue == self.roomTo.integerValue)
            return [NSString stringWithFormat:@"%i", self.roomFrom.integerValue];
        return [NSString stringWithFormat:NSLocalizedString(@"rangeFromToFMT", @""), self.roomFrom.integerValue, self.roomTo.integerValue];
    }
    if (!!self.roomFrom)
        return [NSString stringWithFormat:NSLocalizedString(@"rangeFromFMT", @""), self.roomFrom.integerValue];
    if (!!self.roomTo)
        return [NSString stringWithFormat:NSLocalizedString(@"rangeToFMT", @""), self.roomTo.integerValue];
    return @"???";
}



- (NSString *)humanReadablePriceForm {
    return [NSString stringWithFormat:NSLocalizedString(@"priceExactFMT1KRUB", @""), [NSString stringWithFormat:@"%.1f", roundf(self.priceFrom.integerValue / 500) / 2]];
}


- (NSString *)humanReadablePriceTo {
    return [NSString stringWithFormat:NSLocalizedString(@"priceExactFMT1KRUB", @""), [NSString stringWithFormat:@"%.1f", roundf(self.priceTo.integerValue / 500) / 2]];
}


- (void)clearSearchResults {
    for (SearchResult *result in self.searchResults)
    [result deleteEntity];
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:nil completion:^(BOOL success, NSError *error) {
    }];
}

@end
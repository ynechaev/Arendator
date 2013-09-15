//
//  ARCIANFetcher.m
//  Arendator
//
//  Created by Yury Nechaev on 14.09.13.
//  Copyright (c) 2013 Yury Nechaev. All rights reserved.
//

#import "ARCIANFetcher.h"
#import "Search.h"
#import "TFHpple.h"
#import "DataModel+Helper.h"

@implementation ARCIANFetcher

static NSString *defaultRegion = @"10";
static ARCIANFetcher *instanceFetcher = nil;

static NSString *xpath			= @"//table[@class='cat']//tr";
static NSString *baseURL		= @"http://www.cian.ru/";
static NSString *baseSuffix		= @"cat.php";

// Расположение
/*
 1 - Москва
 2 - Москвоская область
 10 - Санкт-петербург
 11 - Ленинградская область
*/
static NSString *regionKey		= @"region";			// Регион поиска
static NSString *metroKey		= @"metro[%i]";			// Метро

// Тип недвижимости
static NSString *suburbianKey	= @"suburbian";			// Загородный коттедж {yes}
static NSString *officeKey		= @"offices";			// Нежилое помещение {yes}
/*
 Типы помещений:
 1 - Офис					2 - Торговая площадь		3 - Склад
 4 - Общепит				5 - Cвободного назначения	6 - Гараж
 7 - Производственные		8 - Юридический адрес		9 - Под автосервис
 10 - Продажа бизнеса
*/
static NSString *officeType		= @"office_type[%i]";	// Типы помещений. %i - порядковый индекс параметра в url
static NSString *photoKey		= @"wp";				// Только с фото 1, без фото -1, можно без фото 0
static NSString *dateSorterKey  = @"totime";			// За сегодня -2, За 5 минут 300 итд в секундах
static NSString *contextKey 	= @"context";			// Включает слово
static NSString *acontextKey 	= @"acontext";			// Исключает слово

// Особенности объекта
static NSString *notLastFloorKey 	= @"floornl";		// Не последний этаж 1
static NSString *minFloorKey		= @"minfloor";		// Минимальный этаж объекта, полуподвал -1, подвал -2
static NSString *maxFloorKey		= @"maxfloor";		// Максимальный этаж объекта
static NSString *minFloorNKey		= @"minfloorn";		// Минимальное количество этажей всего
static NSString *maxFloorNKey		= @"maxfloorn";		// Максимальное количество этажей всего

// Метраж
static NSString *minKitchenAreaKey 	= @"minkarea";		// Минимальная площадь кухни
static NSString *maxKitchenAreaKey 	= @"maxkarea";		// Максимальная площадь кухни
static NSString *minLivingAreaKey 	= @"minlarea";		// Минимальная жилая площадь
static NSString *maxLivingAreaKey 	= @"maxlarea";		// Максимальная жилая площадь
static NSString *minAllAreaKey 		= @"minarea";		// Минимальная жилая площадь
static NSString *maxAllAreaKey 		= @"maxarea";		// Максимальная жилая площадь

// Условия
static NSString *rentTypeKey 	= @"type";				// Посуточно 2, От нескольких месяцев 3, От месяца 4, Длительно -2
static NSString *rentPriceTypeKey= @"m2";				// Цена указана за метр квадратный 1
static NSString *currencyKey	= @"currency";			// 1 - Доллар, 2 - Рубли, 3 - Евро
static NSString *spacialTax		= @"zerocom";			// Эксклюзивная комиссия 1
static NSString *minPriceKey	= @"minprice";			// Минимальная цена
static NSString *maxPriceKey	= @"maxprice";			// Максимальная цена
static NSString *dealTypeKey 	= @"deal_type"; 		// 1 - Аренда 2 - Продажа
static NSString *cityKey 		= @"city[%i]"; 			// Город
static NSString *unknown1 		= @"obl_id"; 			// Хз
static NSString *roomKey 		= @"room%i"; 			// %i-комнатная квартира, либо комната 0
static NSString *prepayKey 		= @"maxprepay"; 		// Предоплата до количества месяцев (1-6). Любая -1
static NSString *agentFilter 	= @"cl"; 				// -1 Без "агентам не звонить"
static NSString *pledgeKey		= @"pledge"; 			// Без залога -1, С залогом 1

// Удобства
static NSString *tvKey			= @"tv";				// Наличие телевизора
static NSString *washingMchnKey	= @"wm";				// Стиральная машина
static NSString *fridgeKey  	= @"rfgr";				// Холодильник
static NSString *furnitureKey	= @"mebel";				// Наличие мебели
static NSString *kitchenFurnKey = @"medel_k";			// Наличие кухонной мебели
static NSString *phoneKey		= @"phone";				// С телефоном 1
static NSString *petsKey		= @"pets";				// Можно с животными 1
static NSString *kidsKey		= @"kids";				// Можно с детьми 1
static NSString *balkonKey 		= @"minibalkon"; 		// Без балкона -1, Только с балконом 1


+ (ARCIANFetcher *) sharedInstance {
	static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instanceFetcher = [[ARCIANFetcher alloc] init];
    });
    return instanceFetcher;
}

- (void)performSearch:(Search *)search
               onPage:(NSInteger)page
             progress:(void (^)(float progress, kSearchStatus status))progressBlock
               result:(void (^)(BOOL finished, NSArray *searchResults))successBlock
              failure:(void (^)(NSError *error))failureBlock {
    if (progressBlock) progressBlock(0.05, kSearchStatusDataLoading);
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
    NSDictionary *requestParams = [self parametersContructedFromSearch:search onPage:page];
    if (progressBlock) progressBlock(0.25, kSearchStatusDataLoading);
    [httpClient getPath:baseSuffix parameters:requestParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (progressBlock) progressBlock(0.5, kSearchStatusDataParsing);
        NSData *recievedData = ((NSData*)responseObject);
        NSString* newStr = [[NSString alloc] initWithData:recievedData
                                                 encoding:NSWindowsCP1251StringEncoding];
        NSData* encodedData = [newStr dataUsingEncoding:NSUTF16StringEncoding];
        TFHpple *tutorialsParser = [TFHpple hppleWithHTMLData:encodedData];
        NSString *tutorialsXpathQueryString = xpath;
        NSArray *tutorialsNodes = [tutorialsParser searchWithXPathQuery:tutorialsXpathQueryString];
        NSLog(@"Nodes: %i", [tutorialsNodes count]);
        BOOL firstElement = YES;
        NSMutableArray *returnArray = [NSMutableArray new];
        int grandCounter = 0;
        for (TFHppleElement *element in tutorialsNodes) {
            if (firstElement) firstElement = NO;
            else {
                // Creating search result
                SearchResult *sresult = [SearchResult newInstanceForSearch:search];
                int upperCounter = 0;
                for (TFHppleElement *elementChild in element.children) {
                    NSLog(@"~============================{ %i", upperCounter);
                    NSLog(@"%i: Content: %@", upperCounter, element.content);
                    upperCounter += 1;
                    int midCounter = 0;
                    for (TFHppleElement *elementChildChild in elementChild.children) {
                        if (upperCounter == 8 && midCounter == 0) { // Кух. Мебель
                            
                        }
                        if (upperCounter == 10 && midCounter == 0) { // Цена
                            NSLog(@"Price: %@", elementChildChild.content);
                            NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
                            [f setNumberStyle:NSNumberFormatterDecimalStyle];
                            NSNumber * priceNumber = [f numberFromString:elementChildChild.content];
                            sresult.price = priceNumber;
                        }
                        if (upperCounter == 14 && midCounter == 0) { // Этаж х/у
                            NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
                            [f setNumberStyle:NSNumberFormatterDecimalStyle];
                            NSArray *components = [elementChildChild.content componentsSeparatedByString:@"/"];
							sresult.flor = [f numberFromString:[components firstObject]];
                            sresult.florTotal = [f numberFromString:[components lastObject]];
                        }
                        if (upperCounter == 16 && midCounter == 0) { // 6/кух.мебели ? ЧЗХ
                            
                        }
                        if (upperCounter == 16 && midCounter == 2) { // жил.мебель
                            sresult.options = [sresult.options stringByAppendingString:[NSString stringWithFormat:@"%@,",elementChildChild.content]];
                        }
                        if (upperCounter == 16 && midCounter == 4) { // без телефона
                            sresult.options = [sresult.options stringByAppendingString:[NSString stringWithFormat:@"%@,",elementChildChild.content]];
                        }
                        if (upperCounter == 16 && midCounter == 6) { // ТВ
                            sresult.options = [sresult.options stringByAppendingString:[NSString stringWithFormat:@"%@,",elementChildChild.content]];
                        }
                        if (upperCounter == 16 && midCounter == 8) { // холодильник
                            sresult.options = [sresult.options stringByAppendingString:[NSString stringWithFormat:@"%@,",elementChildChild.content]];
                        }
                        if (upperCounter == 16 && midCounter == 10) { //балкон
                            sresult.options = [sresult.options stringByAppendingString:[NSString stringWithFormat:@"%@,",elementChildChild.content]];
                        }
                        NSLog(@"%i,%i: Content: %@", upperCounter,midCounter, elementChildChild.content);
                        midCounter += 1;
                        int counter = 0;
                        for (TFHppleElement *subElement in elementChildChild.children) {
                            NSLog(@"~=========={ %i }===========~", counter);
                            NSLog(@"%i,%i,%i: Sub content: %@", upperCounter,midCounter,counter, elementChildChild.content);
                            counter += 1;
                            int lowerCounter = 0;
                            for (TFHppleElement *sub2Element in subElement.children) {
                                NSLog(@"~========{ %i", lowerCounter);
                                NSLog(@"Sub sub content: %@", sub2Element.content);
                                lowerCounter += 1;
                                for (TFHppleElement *sub3Element in sub2Element.children) {
                                    NSLog(@"Sub sub sub content: %@", sub3Element.content);
                                    for (TFHppleElement *sub4Element in sub3Element.children) {
                                        NSLog(@"Sub sub sub sub content: %@", sub4Element.content);
                                        
                                    }
                                }
                            }
                        }
                    }
                }
                grandCounter += 1;
                [returnArray addObject:sresult];
            }
            NSLog(@"==============================================================");
        }
        if (successBlock) successBlock(YES, returnArray);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failureBlock) failureBlock(error);
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
    }];
}

- (NSDictionary*)parametersContructedFromSearch:(Search*)search onPage:(NSInteger)page {
    NSMutableDictionary *params = [NSMutableDictionary new];
    if (search.allowedChildren.boolValue) [params setObject:@"1" forKey:kidsKey];
    if (search.allowedPets.boolValue) [params setObject:@"1" forKey:petsKey];
// TODO: replace this with valid city ids
    [params setObject:defaultRegion forKey:regionKey];
//    if (search.cityId) [params setObject:search.cityId.stringValue forKey:regionKey];
    if (search.metroIdStr) {
        NSArray *metroArray = [search.metroIdStr componentsSeparatedByString:@","];
        NSMutableDictionary *metroDict = [NSMutableDictionary new]; int counter = 0;
        for (NSString *metro in metroArray) {
            [metroDict setObject:metro forKey:[NSString stringWithFormat:metroKey, counter]];
            counter += 1;
        }
        [params addEntriesFromDictionary:metroDict];
    }
    if (search.optBalcony.boolValue) [params setObject:@"1" forKey:balkonKey];
    if (search.optFridge.boolValue) [params setObject:@"1" forKey:fridgeKey];
    if (search.optFurniture.boolValue) [params setObject:@"1" forKey:furnitureKey];
    if (search.optKitchenFurniture.boolValue) [params setObject:@"1" forKey:kitchenFurnKey];
    if (search.optPhone) [params setObject:@"1" forKey:phoneKey];
    if (search.optTV) [params setObject:@"1" forKey:tvKey];
    if (search.optWashMachine) [params setObject:@"1" forKey:washingMchnKey];
    if (search.priceFrom) [params setObject:search.priceFrom.stringValue forKey:minPriceKey];
    if (search.priceTo) [params setObject:search.priceTo.stringValue forKey:maxPriceKey];
    NSLog(@"%@",params);
    return params;
}

- (void)fetchDataFromURL:(NSURL*)url result:(void (^)(BOOL finished, NSData *data))successBlock
                            onFailure:(void (^)(NSError *error))failureBlock
{
    
}

@end

//
//  AppDelegate.h
//  obj-c-sqllite
//
//  Created by sehio on 11.07.2021.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface Model : NSObject

- (void) openDB;
- (void) closeDB;

@end

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

- (void) addEmployeeWithFirstName:(NSString *)firstName
                              lastName:(NSString *)lastName
                                 phone:(NSString *)phone;
- (void) deleteEmployeeWithID:(NSNumber *)empID;
- (NSArray *)allEmployees;

@end

//
//  CMWXContactsModule.m
//  WeexDemo
//
//  Created by yMac on 2019/3/25.
//  Copyright © 2019 wusx. All rights reserved.
//

#import "CMWXContactsModule.h"
#import <Contacts/Contacts.h>
#import <AddressBook/AddressBook.h>
#import <MJExtension.h>

@implementation CMWXContactsModule

WX_EXPORT_METHOD(@selector(getContacts:))

+ (void)load {
    [WXSDKEngine registerModule:@"contacts" withClass:[CMWXContactsModule class]];
}

- (void)getContacts:(WXModuleKeepAliveCallback)callBack {
    
    if (@available(iOS 9.0, *)) {
        CNAuthorizationStatus authStatus = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        if (authStatus == CNAuthorizationStatusNotDetermined) {
            // 第一次申请权限
            CNContactStore *contactStore = [[CNContactStore alloc] init];
            [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                if (granted) {
                    
                    [self getContactsAfterAuth:callBack];
                } else {
                    
                    if (callBack) {
                        callBack(@"授权失败",YES);
                    }
                }
            }];
        } else {
            
            [self getContactsAfterAuth:callBack];
        }
    } else {
        // Fallback on earlier versions
        ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
            // 第一次申请权限
            ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
                
                if (granted) {
                    
                    [self getContactsAfterAuth:callBack];
                } else {
                    
                    if (callBack) {
                        callBack(@"授权失败",YES);
                    }
                }
            });
            
        } else {
            
            [self getContactsAfterAuth:callBack];
        }
    }
    
}

- (void)getContactsAfterAuth:(WXModuleKeepAliveCallback)callBack {
    
    /// 结果数组
    NSMutableArray *resultArray = [NSMutableArray new];
    if (@available(iOS 9.0, *)) {
        
        CNAuthorizationStatus authorizationStatus = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        if (authorizationStatus == CNAuthorizationStatusDenied) {
            if (callBack) {
                callBack(@"用户未授权",YES);
            }
            return;
        }
        
        // 获取指定的字段,并不是要获取所有字段，需要指定具体的字段
        NSArray *keysToFetch = @[CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey];
        CNContactFetchRequest *fetchRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:keysToFetch];
        CNContactStore *contactStore = [[CNContactStore alloc] init];
        
        [contactStore enumerateContactsWithFetchRequest:fetchRequest error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
            NSString *givenName = contact.givenName;
            NSString *familyName = contact.familyName;
            /// 结果字典
            NSMutableDictionary *resultDic = [NSMutableDictionary new];
            [resultDic setObject:[NSString stringWithFormat:@"%@%@",familyName,givenName] forKey:@"name"];
            
            NSArray *phoneNumbers = contact.phoneNumbers;
            NSMutableArray *resultPhoneNumbers = [NSMutableArray arrayWithCapacity:phoneNumbers.count];
            
            for (CNLabeledValue *labelValue in phoneNumbers) {
                CNPhoneNumber *phoneNumber = labelValue.value;
                [resultPhoneNumbers addObject:phoneNumber.stringValue];
            }
            /// 电话数组赋值
            [resultDic setObject:resultPhoneNumbers forKey:@"phones"];
            [resultArray addObject:resultDic];
        }];
        
    } else {
        // Fallback on earlier versions
        
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied) {
            if (callBack) {
                callBack(@"授权失败",YES);
            }
            return;
        }
        
        CFErrorRef *error = NULL;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
        CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
        
        for ( int i = 0; i < numberOfPeople; i++) {
            ABRecordRef person = CFArrayGetValueAtIndex(people, i);
            
            NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
            NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
            /// 结果字典
            NSMutableDictionary *resultDic = [NSMutableDictionary new];
            [resultDic setObject:[NSString stringWithFormat:@"%@%@",lastName,firstName] forKey:@"name"];
            //读取电话多值
            ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
            NSMutableArray *resultPhoneNumbers = [NSMutableArray new];
            for (int k = 0; k < ABMultiValueGetCount(phone); k++) {
                //获取該Label下的电话值
                NSString * personPhone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phone, k);
                                [resultPhoneNumbers addObject:personPhone];
            }
            /// 电话数组赋值
            [resultDic setObject:resultPhoneNumbers forKey:@"phones"];
            [resultArray addObject:resultDic];
        }
    }
    /// callback在这里
    if (callBack) {
        callBack([resultArray mj_JSONString],YES);
    }
    
}

@end

//
//  JWBluetoothManage.m
//  JWBluetoothPrinte
//
//  Created by 张竟巍 on 2017/6/14.
//  Copyright © 2017年 张竟巍. All rights reserved.
//

#import "WeexBluetoothManage.h"


static WeexBluetoothManage * manage = nil;

@interface WeexBluetoothManage () <CBCentralManagerDelegate,CBPeripheralDelegate>

@property (nonatomic, strong)   CBCentralManager             *centralManager;           //  服务设备管理器

@property (nonatomic, strong)   NSMutableArray               *peripherals;             //  搜索到的蓝牙设备数组
@property (nonatomic, strong)   NSMutableArray               *rssis;                   //  搜索到的蓝牙设备列表信号强度数组
@property (nonatomic, strong)   NSMutableArray               *printeChatactersArray;   //  可以打印的的特性数组

@property (nonatomic, copy)     JWScanPerpheralsSuccess        scanPerpheralSuccess;   // 扫描设备成功的回调
@property (nonatomic, copy)     JWScanPeripheralFailure        scanPerpheralFailure;   // 扫描设备失败的回调
@property (nonatomic, copy)     JWConnectPeripheralCompletion  connectCompletion;      // 连接完成的回调
@property (nonatomic, copy)     JWPrintResultBlock              printResult;           // 打印结果的回调

//此参数是为了计算打印有没有出错
@property (nonatomic, assign)   BOOL                         autoConnect;              // 是否自动连接
@property (nonatomic, assign)   NSInteger                    writeCount;               // 写入次数
@property (nonatomic, assign)   NSInteger                    responseCount;            //  返回次数


/// 数据源
@property (nonatomic, strong) NSMutableDictionary<NSString *, CBPeripheral *> *peripheralsDicts;
/// 返回给weex的字典
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *resultPeripherals;

@end

@implementation WeexBluetoothManage

#pragma mark - Singleton Medth

+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manage = [[WeexBluetoothManage alloc] init];
    });
    return manage;
}
- (instancetype)init{
    if (self = [super init]) {
        [self _initBluetooth];
    }
    return self;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manage = [super allocWithZone:zone];
    });
    
    return manage;
}
- (void) _initBluetooth{
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    [self.peripherals removeAllObjects];
    [self.rssis removeAllObjects];
    [self.printeChatactersArray removeAllObjects];
    _connectedPerpheral = nil;
}
#pragma mark - Bluetooth Medthod
//开始搜索
- (void)beginScanPerpheralSuccess:(JWScanPerpheralsSuccess)success failure:(JWScanPeripheralFailure)failure{
    //block 赋值
    _scanPerpheralSuccess = success;
    _scanPerpheralFailure = failure;
    if (_centralManager.state == CBManagerStatePoweredOn) {
        //开启搜索
        NSLog(@"开启扫描");
        [_centralManager scanForPeripheralsWithServices:nil options:nil];
        return;
    }
    //防止因为权限问题造成BUG
    [self _initBluetooth];
}
#pragma mark - CBCentralManagerDelegate Medthod
//权限改变重新搜索设备
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    if (central.state != CBManagerStatePoweredOn) {
        if (_scanPerpheralFailure) {
            _scanPerpheralFailure(central.state);
        }
    }else{
        [central scanForPeripheralsWithServices:nil options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI{
    NSLog(@"扫描中....");
    if (peripheral.name.length <= 0) {
        return ;
    }
    
    /// 数据源
    [self.peripheralsDicts setObject:peripheral forKey:peripheral.identifier.UUIDString];
    /// 给weex的数据源
    [self.resultPeripherals setObject:peripheral.name forKey:peripheral.identifier.UUIDString];
    
    if (_scanPerpheralSuccess) {
        _scanPerpheralSuccess(self.resultPeripherals,_rssis);
    }
    
    if (_autoConnect) {
        NSString * uuid = GetLastConnectionPeripheral_UUID();
        if ([peripheral.identifier.UUIDString isEqualToString:uuid]) {
            peripheral.delegate = self;
            [_centralManager connectPeripheral:peripheral options:nil];
        }
    }
}
#pragma mark - 连接外设 Medthod
- (void)connectPeripheral:(NSString *)UUIDString completion:(JWConnectPeripheralCompletion)completion{
    _connectCompletion = completion;
    if (_connectedPerpheral) {
        
        [self cancelPeripheralConnection:_connectedPerpheral];
    }
    CBPeripheral *peripheral = self.peripheralsDicts[UUIDString];
    if (!peripheral) {
        return;
    }
    [self connectPeripheral:peripheral];
}
//连接外设设置代理
- (void)connectPeripheral:(CBPeripheral *)peripheral{
    [_centralManager connectPeripheral:peripheral options:nil];
    peripheral.delegate = self;
}
- (void)autoConnectLastPeripheralCompletion:(JWConnectPeripheralCompletion)completion{
    _connectCompletion = completion;
    _autoConnect = YES;
    
    if (_centralManager.state == CBManagerStatePoweredOn) {
        //开启搜索
        NSLog(@"开启扫描");
        [_centralManager scanForPeripheralsWithServices:nil options:nil];
    }
    
}
- (void)cancelPeripheralConnection:(CBPeripheral *)peripheral{
    if (!peripheral) {
        return;
    }
    //去除次自动连接
    RemoveLastConnectionPeripheral_UUID();
    
    [_centralManager cancelPeripheralConnection:peripheral];
    _connectedPerpheral = nil;
    //取消连接 清除可打印输入
    [_printeChatactersArray removeAllObjects];
}
- (void)cancelPeripheralConnectionWithUUID:(NSString *)UUIDString {
    CBPeripheral *peripheral = self.peripheralsDicts[UUIDString];
    if (!peripheral) {
        return;
    }
    //去除次自动连接
    RemoveLastConnectionPeripheral_UUID();
    
    [_centralManager cancelPeripheralConnection:peripheral];
    _connectedPerpheral = nil;
    //取消连接 清除可打印输入
    [_printeChatactersArray removeAllObjects];
}

- (void)stopScanPeripheral{
    [_centralManager stopScan];
}

#pragma mark - 连接外设代理 Medthod
//成功连接
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    //当前设备赋值
    _connectedPerpheral = peripheral;
    //存入标识符  下次自动
    SetLastConnectionPeripheral_UUID(peripheral.identifier.UUIDString);
    //链接成功 停止扫描
    [_centralManager stopScan];
    if (_connectCompletion) {
        _connectCompletion(peripheral,nil);
    }
    _stage = JWScanStageConnection;
    peripheral.delegate = self;
    //发现服务 扫描服务
    //CBUUID *macServiceUUID = [CBUUID UUIDWithString:@"180A"];
    //[peripheral discoverServices:@[[CBUUID UUIDWithString:@"180A"]]];
    [peripheral discoverServices:nil];
}
//连接失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error{
    if (_connectCompletion) {
        _connectCompletion(peripheral,error);
    }
    _stage = JWScanStageConnection;
}
//断开连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error{
    _connectedPerpheral = nil;
    [_printeChatactersArray removeAllObjects];
    
    if (_disConnectBlock) {
        _disConnectBlock(peripheral,error);
    }
    _stage = JWScanStageConnection;
}
#pragma mark 蓝牙服务代理
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error{
    if (error) {
        NSLog(@"发现服务出错 错误原因-%@",error.domain);
    }else{
        for (CBService *service in peripheral.services) {
            [peripheral discoverCharacteristics:nil forService:service];
            if ([service.UUID isEqual:[CBUUID UUIDWithString:@"180A"]]) {
                [peripheral discoverCharacteristics:nil forService:service];
            }
//             CBUUID *macCharcteristicUUID = [CBUUID UUIDWithString:@"2A23"];
//            [peripheral discoverCharacteristics:@[macCharcteristicUUID] forService:service];
        }
    }
    _stage = JWScanStageServices;
}
#pragma mark 蓝牙服务特性代理
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error{
    if (error) {
        NSLog(@"发现特性出错 错误原因-%@",error.domain);
    }else{
        for (CBCharacteristic *character in service.characteristics) {
            CBCharacteristicProperties properties = character.properties;
            if (properties & CBCharacteristicPropertyWrite) {
                NSDictionary *dict = @{@"character":character,@"type":@(CBCharacteristicWriteWithResponse)};
                [_printeChatactersArray addObject:dict];
                NSLog(@"%p------%p",character.UUID,[CBUUID UUIDWithString:@"2A23"]);

                //[peripheral readValueForCharacteristic:character];
            }
        }
    }
    if (_printeChatactersArray.count > 0) {
        _stage = JWScanStageCharacteristics;
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSString *value = [NSString stringWithFormat:@"%@",characteristic.value];
    NSMutableString *macString = [[NSMutableString alloc] init];
    [macString appendString:[[value substringWithRange:NSMakeRange(16, 2)] uppercaseString]];
    [macString appendString:@":"];
    [macString appendString:[[value substringWithRange:NSMakeRange(14, 2)] uppercaseString]];
    [macString appendString:@":"];
    [macString appendString:[[value substringWithRange:NSMakeRange(12, 2)] uppercaseString]];
    [macString appendString:@":"];
    [macString appendString:[[value substringWithRange:NSMakeRange(5, 2)] uppercaseString]];
    [macString appendString:@":"];
    [macString appendString:[[value substringWithRange:NSMakeRange(3, 2)] uppercaseString]];
    [macString appendString:@":"];
    [macString appendString:[[value substringWithRange:NSMakeRange(1, 2)] uppercaseString]];
    NSLog(@"mac == %@",macString);
}

#pragma mark 写入数据  跟block
// 发送数据时，需要分段的长度，部分打印机一次发送数据过长就会乱码，需要分段发送。这个长度值不同的打印机可能不一样，你需要调试设置一个合适的值（最好是偶数）
#define kLimitLength    146

- (void)sendPrintData:(NSData *)data completion:(JWPrintResultBlock)result{
    if (!self.connectedPerpheral) {
        if (result) {
            result(NO,_connectedPerpheral,@"未连接蓝牙设备");
        }
        return;
    }
    if (self.printeChatactersArray.count == 0) {
        if (result) {
            result(NO,_connectedPerpheral,@"该蓝牙设备不支持写入数据");
        }
        return;
    }
    NSDictionary *dict = [_printeChatactersArray lastObject];
    _writeCount = 0;
    _responseCount = 0;
    
    // 如果kLimitLength 小于等于0，则表示不用分段发送
    if (kLimitLength <= 0) {
        _printResult = result;
        [_connectedPerpheral writeValue:data forCharacteristic:dict[@"character"] type:[dict[@"type"] integerValue]];
        _writeCount ++;
        return;
    }
    
    if (data.length <= kLimitLength) {
        _printResult = result;
        [_connectedPerpheral writeValue:data forCharacteristic:dict[@"character"] type:[dict[@"type"] integerValue]];
        _writeCount ++;
    } else {
        //分段打印
        NSInteger index = 0;
        for (index = 0; index < data.length - kLimitLength; index += kLimitLength) {
            NSData *subData = [data subdataWithRange:NSMakeRange(index, kLimitLength)];
            [_connectedPerpheral writeValue:subData forCharacteristic:dict[@"character"] type:[dict[@"type"] integerValue]];
            _writeCount++;
        }
        _printResult = result;
        NSData *leftData = [data subdataWithRange:NSMakeRange(index, data.length - index)];
        if (leftData) {
            [_connectedPerpheral writeValue:leftData forCharacteristic:dict[@"character"] type:[dict[@"type"] integerValue]];
            _writeCount++;
        }
    }
}

- (void)sendTscPrintData:(NSData *)data completion:(JWPrintResultBlock)result {
    
    if (!self.connectedPerpheral) {
        if (result) {
            result(NO,_connectedPerpheral,@"未连接蓝牙设备");
        }
        return;
    }
    if (self.printeChatactersArray.count == 0) {
        if (result) {
            result(NO,_connectedPerpheral,@"该蓝牙设备不支持写入数据");
        }
        return;
    }
    NSDictionary *dict = [_printeChatactersArray lastObject];
    [self.connectedPerpheral writeValue:data forCharacteristic:dict[@"character"] type:CBCharacteristicWriteWithResponse];
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error{
    if (!_printResult) {
        return;
    }
    _responseCount ++;
    if (_writeCount != _responseCount) {
        return;
    }
    if (error) {
        _printResult(NO,_connectedPerpheral,@"发送失败");
    } else {
        _printResult(YES,_connectedPerpheral,@"已成功发送至蓝牙设备");
    }
}

#pragma mark - init containers

- (NSMutableArray *)peripherals{
    if (!_peripherals) {
        _peripherals = @[].mutableCopy;
    }
    return _peripherals;
}
- (NSMutableArray *)rssis{
    if (!_rssis) {
        _rssis = @[].mutableCopy;
    }
    return _rssis;
}
-(NSMutableArray *)printeChatactersArray{
    if (!_printeChatactersArray) {
        _printeChatactersArray = @[].mutableCopy;
    }
    return _printeChatactersArray;
}
- (NSMutableDictionary *)peripheralsDicts {
    if (!_peripheralsDicts) {
        _peripheralsDicts = [NSMutableDictionary new];
    }
    return _peripheralsDicts;
}
- (NSMutableDictionary<NSString *,NSString *> *)resultPeripherals {
    if (!_resultPeripherals) {
        _resultPeripherals = [NSMutableDictionary new];
    }
    return _resultPeripherals;
}


NSString * GetLastConnectionPeripheral_UUID(){
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *uuid = [userDefaults objectForKey:@"BluetoothPeripheral_uuid"];
    return uuid;
}

void SetLastConnectionPeripheral_UUID(NSString * uuid){
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:uuid forKey:@"BluetoothPeripheral_uuid"];
    [userDefaults synchronize];
}
void RemoveLastConnectionPeripheral_UUID(){
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"BluetoothPeripheral_uuid"];
    [userDefaults synchronize];
}
@end

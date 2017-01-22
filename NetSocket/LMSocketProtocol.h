//
//  LMSocketProtocol.h
//  NetSocket
//
//  Created by Flame Grace on 2017/1/21.
//  Copyright © 2017年 hello. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LMSocketProtocol <NSObject>


/**
 接收到新数据
 @param data 新数据
 */
- (void)didRecieveData:(NSData *)data;
/**
 已经建立链接
 */
- (void)didConnect;
/**
 已经失去链接
 */
- (void)didDisConnect;
/**
 数据发送成功
 */
- (void)didSendData;
/**
 接收到新的链接
 */
- (void)didAcceptNewSocket:(id<LMSocketProtocol>)newSocket;


/**
 链接到某个服务器
 @param host 地址
 @param port 端口
 @return 成功与否
 */
- (BOOL)connectHost:(NSString *)host port:(uint32_t)port;

/**
 建立一个服务器
 @param port 端口
 @return 是否成功
 */
- (BOOL)acceptOnPort:(uint32_t)port error:(NSError **)error;

/**
 发送数据
 @param data 数据
 */
- (void)sendData:(NSData *)data;

/**
 开始读取数据
 */
- (void)receiveData;

/**
 关闭链接
 */
- (void)close;

@end

//
//  LMSocket.h
//  NetSocket
//
//  Created by FlameGrace on 2017/1/20.
//  Copyright © 2017年 hello. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LMSocketDelegate.h"

const static NSString *NetSocketErrorDomain;

/**
阻塞的TCP Socket服务器客户端实现方式， 使用C接口完成
 */
@interface LMSocket : NSObject <LMSocketProtocol>

/**
 测试用的名称标识
 */
@property (strong, nonatomic) NSString *name;

@property (weak, nonatomic) id <LMSocketDelegate> delegate;

@property (readonly, nonatomic) NSString *connectHost;

@property (readonly, nonatomic) uint32_t connectPort;

@property (readonly, nonatomic) uint32_t bindPort;

@property (readonly, nonatomic) BOOL isBind;

@property (readonly, nonatomic) BOOL isConnected;


/**
 初始化一个socket
 @param delegate 代理对象
 @param delegateQueue 处理代理调用的线程
 */
- (instancetype)initWithDelete:(id <LMSocketDelegate>)delegate delegateQueue:(dispatch_queue_t)delegateQueue;

@end

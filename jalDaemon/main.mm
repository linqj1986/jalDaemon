//
//  main.c
//  jalDaemon
//
//

#include <UIKit/UIKit.h>
#include <stdio.h>
#include <unistd.h>

extern "C" CFNotificationCenterRef CFNotificationCenterGetDistributedCenter(void);
void shellcmd(char* cmd,char* buff,int size);

static void NotificationReceivedCallback(CFNotificationCenterRef center,void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    NSString *friendlyNSString = (__bridge NSString *)object;
    NSLog(@"lqj-jalDaemon:%@",friendlyNSString);
    
    char cBuf[1024] = {0};
    shellcmd("killall -9 mDNSResponder \n killall -9 mDNSResponderHelper",cBuf,1024);
}

void shellcmd(char* cmd,char* buff,int size)
{
    char temp[10240] = {0};
    FILE* fp = NULL;
    int offset = 0;
    int len;
    do {
        fp = popen(cmd, "r");
        if(fp == NULL)
        {
            break;
        }
        
        while(fgets(temp, sizeof(temp), fp) != NULL)
        {
            len = (int)strlen(temp);
            if(offset + len < size)
            {
                strcpy((char*)buff + offset, temp);
                offset += len;
            }
            else
            {
                buff[offset] = 0;
                break;
            }
        }
        
        if(fp != NULL)
        {
            pclose(fp);
        }
        
    } while (0);
}

int main (int argc, const char * argv[])
{
    printf("lqj-Hello, jalDaemon!\n");
    
    CFNotificationCenterAddObserver(CFNotificationCenterGetDistributedCenter(),
                                    NULL,
                                    &NotificationReceivedCallback,
                                    CFSTR("com.lqj.jalDaemon-notify"),
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
    
    CFRunLoopRun();
	return 0;
}


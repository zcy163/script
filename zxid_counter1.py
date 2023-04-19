#! /usr/bin/python
# -*- coding:utf-8 -*-
# @Author:  zhaochenyang
# @Time:    2022/11/08

from imp import reload
import sys
import subprocess
from unittest import result

if sys.getdefaultencoding() != 'utf-8':
    reload(sys)
    sys.setdefaultencoding('utf-8')

def get_counter():
    cmd_res = subprocess.Popen("echo srvr|nc 127.0.0.1 2181 | grep Zxid | awk '{print $2}'",stdout=subprocess.PIPE,shell=True)
    cmd = "echo 'obase=2;ibase=16;'" + cmd_res.stdout.read()[2:-1].upper() + " | bc"
    cmd_res = subprocess.Popen(cmd,stdout=subprocess.PIPE,shell=True)
    cmd = "echo 'obase=10;ibase=2;'" + cmd_res.stdout.read()[-32:].replace("\n","") + " | bc"
    cmd_res = subprocess.Popen(cmd,stdout=subprocess.PIPE,shell=True)
    cmd_result =  cmd_res.stdout.read()
    return cmd_result


if __name__ == "__main__":
    if int(get_counter()) >= 2**31:
        leader_res = subprocess.Popen("echo mntr|nc 127.0.0.1 2181 | grep leader ",stdout=subprocess.PIPE,shell=True)
        if leader_res.stdout.read():
            # 是leader 赋值1
            whether_leader = 1
            # 大于2的31 打印zxid的counter_number
            out_str = "metric=zkzxid_counter_check" + "|value=" + str(get_counter()).strip() + "|type=gauge|tags=zkzxid_counter_check"
            print out_str
            # 大于2的31 打印是leader的值 1
            out_str1 = "metric=zk_whether_leader" + "|value=" + str(whether_leader) + "|type=gauge|tags=zk_whether_leader"
            print out_str1
        else:
            # 未大于2的31 只打印leader的值0
            # 不是leader 赋值0
            whether_leader = 0
            # 未大于2的31 打印zxid的counter_number
            out_str = "metric=zkzxid_counter_check" + "|value=" + str(get_counter()).strip() + "|type=gauge|tags=zkzxid_counter_check"
            print out_str
            out_str1 = "metric=zk_whether_leader" + "|value=" + str(whether_leader) + "|type=gauge|tags=zk_whether_leader"
            print out_str1
    else:
        # 未大于2的31 只打印leader的值0
        # 不是leader 赋值0
        whether_leader = 0
        # 未大于2的31 打印zxid的counter_number
        out_str = "metric=zkzxid_counter_check" + "|value=" + str(get_counter()).strip() + "|type=gauge|tags=zkzxid_counter_check"
        print out_str
        out_str1 = "metric=zk_whether_leader" + "|value=" + str(whether_leader) + "|type=gauge|tags=zk_whether_leader"
        print out_str1














    
    
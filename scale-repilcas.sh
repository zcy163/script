#!/usr/bin/bash
# @Time    : 2023/2/9
# @File    : scale_replicas
# @Author  : zhaochenyang
# @Version : v1.0
 
# 控制器类型
controller='deploy'
# ns
namespaces='default'
# 副本数
replicas_num='3'
# 控制器组件名
assembly='nginx'
# 备份路径
bak_dir="/tmp/${controller}_${assembly}_repliacas.yaml.bak"


get_replicas(){
    echo `kubectl get $controller $assembly -n $namespaces -ojsonpath='{..replicas}' | awk '{print $1}'`
}

check_replicas(){
    if [ $? == 0 ]
    then
        echo "副本数修改成功"
    else
        echo "修改失败,请检查设定的副本数信息"
        exit 0
    fi
        echo "######### 修改后的配置 #########"
        sleep 3
        get_replicas
        kubectl get $controller $assembly  -n $namespaces 
}

set_replicas(){
    kubectl get $controller $assembly -n $namespaces
    if [ $? == 0 ]
    then
        r_num=`kubectl get $controller $assembly -n $namespaces -ojsonpath='{..replicas}' | awk '{print $1}'`
        if [ ${replicas_num} == ${r_num} ]
        then
            echo "当前副本数为：${replicas_num} 不做修改处理"
            exit 0
        else
            echo "######### 修改前的配置 #########"
            get_replicas
            echo -e "备份${controller}_${assembly}_${namespaces} > ${bak_dir}"
            kubectl get $controller $assembly -n $namespaces -oyaml > $bak_dir
            echo "已备份${controller}_${assembly}_${namespaces}.yaml"
            echo $bak_dir
            echo "进行修改${controller}_${assembly}_${namespaces}资源"
            kubectl scale --replicas=${replicas_num} ${controller}/${assembly} -n ${namespaces}
            check_replicas       
        fi
    else
    echo "获取contorller资源${controller}_${assembly}_${namespaces}失败,不做修改处理"
    exit 0
    fi   
}

set_replicas
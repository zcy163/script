#!/usr/bin/bash
# @Time    : 2022/11/24
# @File    : set_resources
# @Author  : zhaochenyang
# @Version : v1.0
 
# 控制器类型
controller='deploy'
# ns
namespaces='default'
# 控制器组件名
assembly='nginx'
# pod名
pod_name='mypod'
# 容器
container='mycontainer'
# 备份路径
bak_dir="/tmp/${controller}_${assembly}.yaml.bak"

# 指定修改的资源信息(需带单位：cpu=200m,memory=512Mi)
resources='controller/container'
code='limits_cpu/limits_mem/requests_cpu/requests_mem'
value=200m
value=324Mi
# 查看pod中的containers： kubectl get po mypod -n myns -o jsonpath='{.spec.containers.name}'
# 存在多个containers时通过-c 指定对应的container
# 查看指定容器的resources： kubectl get po mypod -n myns -o jsonpath='{$.spec.containers[?(@.name="mycontainer").resources]}'
# 获取指定容器的resources： kubectl get po mypod -n myns -o jsonpath='{range .spec.containers[*]}[{.name}{.resources}]{"\n"}{end}' | awk -F "]]"  "{for(i=1;i<=NF;i++) {printf("%s\n","$i")}}" |sed 's/\[//g' | sed 's/\]//g'





get_resources_controller(){
    echo `kubectl get $controller $assembly -n $namespaces -ojsonpath='{..resources}'`
}


check_resources_controller(){
    if [ $? == 0 ]
    then
        echo "修改成功"
    else
        echo "修改失败,检查配置的资源信息值"
        exit 0
    fi
        echo "######### 修改后的配置 #########"
        get_resources_controller 
}

check_controller(){
    containers_names_0=`kubectl get $controller $assembly -n $namespaces -o jsonpath='{range .spec.template.spec.containers[*]}[{.name}]{"\n"}{end}' |sed 's/\[//g' | sed 's/\]//g'`
    if [ $containers_names_0 == 1]
    then
        kubectl get $controller $assembly  -n $namespaces 
        if [ $? == 0 ]
        then
            echo "######### 修改前的配置 #########"
            get_resources_controller
            echo -e "备份${controller}_${assembly}_${namespaces} > ${bak_dir}"
            kubectl get $controller $assembly -n $namespaces -oyaml > $bak_dir
            echo "已备份${controller}_${assembly}_${namespaces}.yaml"
            echo $bak_dir
            echo "进行修改${controller}_${assembly}_${namespaces}资源"
        else
        echo "获取contorller资源${controller}_${assembly}_${namespaces}失败,不做修改处理"
        exit 0
        fi
    else
      echo "资源${controller}_${assembly}_${namespaces}存在多个容器,请选择container方式修改"
      exit 0
    fi    
}




get_resources_container(){
    kubectl get $controller $assembly -n $namespaces -o jsonpath='{range .spec.template.spec.containers[*]}[{.name}{.resources}]{"\n"}{end}' |sed 's/\[//g' | sed 's/\]//g' |sed 's/map/  /g'| grep $container
}


check_resources_container(){
    if [ $? == 0 ]
    then
        echo "修改成功"
    else
        echo "修改失败,检查配置的资源信息值"
        exit 0
    fi
        echo "######### 修改后的配置 #########"
        get_resources_container 
}


containers_names=`kubectl get $controller $assembly -n $namespaces -o jsonpath='{range .spec.template.spec.containers[*]}[{.name}]{"\n"}{end}' |sed 's/\[//g' | sed 's/\]//g'`
check_container(){
    if grep -q "$containers_names" <<< "$container"
    then
        echo "######### 修改前的配置 #########"
        get_resources_container
        echo -e "备份${controller}_${assembly}_${container}_${namespaces} > ${bak_dir}"
        kubectl get $controller $assembly -n $namespaces -oyaml > $bak_dir
        echo "已备份${controller}_${assembly}_${container}.yaml"
        echo $bak_dir
        echo "进行修改${controller}_${assembly}_${container}}资源"
    else
    echo "获取container资源${controller}_${assembly}_${container}失败,不做修改处理"
    exit 0
fi
}

case $resources in
    "controller")
           if [[ $code == "limits_cpu" ]]
           then
                check_controller
                kubectl set resources  $controller $assembly -n $namespaces --limits=cpu=$value
                check_resources_controller
            elif [[ $code == "limits_mem" ]]
            then
                check_controller
                kubectl set resources  $controller $assembly -n $namespaces --limits=memory=$value
                check_resources_controller
            elif [[ $code == "requests_cpu" ]]
            then
                check_controller
                kubectl set resources  $controller $assembly -n $namespaces --requests=cpu=$value
                check_resources_controller
            elif [[ $code == "requests_mem" ]]
            then
                check_controller
                kubectl set resources  $controller $assembly -n $namespaces --requests=memory=$value
                check_resources_controller
            else
                echo "controller_limits/requests输入错误,不做修改处理"
                exit 0
            fi
            ;;
    "container")
           if [[ -z $container ]]
           then
                echo "请填写一个container: ${containers_names}"
                exit 0
           fi
           if [[ $code == "limits_cpu" ]]
           then
                check_container
                kubectl set resources  $controller $assembly -c $container -n $namespaces --limits=cpu=$value
                check_resources_container
            elif [[ $code == "limits_mem" ]]
            then
                check_container
                kubectl set resources  $controller $assembly -c $container -n $namespaces --limits=memory=$value
                check_resources_container
            elif [[ $code == "requests_cpu" ]]
            then
                check_container
                kubectl set resources  $controller $assembly -c $container -n $namespaces --requests=cpu=$value
                check_resources_container
            elif [[ $code == "requests_mem" ]]
            then
                check_container 
                kubectl set resources  $controller $assembly -c $container -n $namespaces --requests=memory=$value
                check_resources_container
            else
                echo "container_limits/requests输入错误,不做修改处理"
                exit 0
            fi
            ;;   
    *)
       echo "资源类型${resources}输入错误,不做修改处理"
                exit 0
                ;; 
    esac

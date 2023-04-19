#!/usr/bin/bash 
################################################################################
#
# 
#
################################################################################
# @Time    : 2022/09/05
# @File    : resources_check
# @Author  : zhaochenyang
# @Version : v1.0


# functions
# 制表
# 设置行，可以是表头，也可以是表格内容。
# 如果是表格内容，“—”表示空值
setRow(){
    value=$*
    table=${table}"|${value// /#|}#|\n"
}

# 行分隔线
# 入参：表格的列数。
splitLine(){
    local num=`expr $1 + 2`
    split=`seq -s '+#' $num | sed 's/[0-9]//g'`    
    table=${table}"${split}\n"
}

#绘制表格
#入参：table
setTable(){
    echo -e $1|column -s "#" -t|awk '{if($0 ~ /^+/){gsub(" ","-",$0);print $0}else{print $0}}'
}


# functions
# 高亮显示
# red_echo() {
#     echo -e "FAILED:\033[31m$@\033[0m"
# }

# 为真判断
ture_if() {
    if [ $? == 0 ]
    then 
      continue
    fi 
}
# 定义资源清单数组
NS="tce"
DS=(deploy statefulset)
CMR=(replicas cpu mem nodeselector hostnetwork)
DEPLOY_LIST_lC=()
STATEFULSET_LIST_LC=()

# functions
# get deploys/satefulsets
get_image_dep_state() {
    for i in `kubectl get deploy  -n $NS | awk '{print $1}'`;
    do
        if [ $i !== "NAME" ];
        then
            DEPLOY_LIST[$num_dep]=$i
            let num_dep++ 
        fi 
    done

    for i in `kubectl get statefulset  -n $NS | awk '{print $1}'`;
    do
        if [ $i !== "NAME" ];
        then
            STATEFULSET_LIST[$num_sta]=$i
            let num_sta++ 
        fi 
    done
} 



# 定义数据信息
SECRET_NAME="dbsql-tcenter-dc-passage"   
NS="tce"
DB_NAME="db_tce_flexible_delivery"
TABLE_NAME="t_component_capacity"
IPV4=$(echo `kubectl get secret ${SECRET_NAME} -n ${NS} -o yaml | grep ipv4 | awk '{print $2}'` | base64 -d)
PORT=$(echo `kubectl get secret ${SECRET_NAME} -n  ${NS} -o yaml | grep port | awk '{print $2}'` | base64 -d)
USER=$(echo `kubectl get secret ${SECRET_NAME} -n  ${NS} -o yaml | grep user | awk '{print $2}'` | base64 -d)
PASS=$(echo `kubectl get secret ${SECRET_NAME} -n  ${NS} -o yaml | grep pass | awk 'NR==1{print $2}'` | base64 -d)

# get mysql 数据
get_mysql=`mysql -h${IPV4} -P${PORT} -u${USER} -p${PASS}  ${DB_NAME} -Bse "select * from $TABLE_NAME;"`





# get replicas 
get_replicas_diff() {
    table=""
    splitLine 4
    setRow "podname" "运行副本数" "数据库中存放的副本数" "是否一致"
    splitLine 4
    for (( line=0;line<=${#DEPLOY_LIST[@]};line++ ));
    do
       rep=`kubectl get deployment ${DEPLOY_LIST[$line]} -n tce -o yaml |  egrep replicas:.*| awk 'NR==2{print $2}'`
       rep_sq=`$get_mysql | grep ${DEPLOY_LIST[$line]} | awk '{print $2}'| awk -F ',' '{print$9}' | awk -F ':' '{print $2}' | grep -o '[0-9]*'`
       if [ $rep == $rep_sq ]
        then
        setRow "${DEPLOY_LIST[$line]}" "$rep" "$rep_sq" "是"
        splitLine 4
        else 
        setRow "${DEPLOY_LIST[$line]}" "$rep" "$rep_sq" "否"
        splitLine 4
       fi
    done

    for (( line=0;line<=${#STATEFULSET_LIST_LC[@]};line++ ));
    do
       rep=`kubectl get satefulset ${STATEFULSET_LIST_LC[$line]} -n tce -o yaml |  egrep replicas:.*| awk 'NR==2{print $2}'`
       rep_sq=`$get_mysql | grep ${DEPLOY_LIST[$line]} | awk '{print $2}'| awk -F ',' '{print$9}' | awk -F ':' '{print $2}' | grep -o '[0-9]*'`
       if [ $rep == $rep_sq ]
        then
        setRow "${STATEFULSET_LIST_LC[$line]}" "$rep" "$rep_sq" "是"
        splitLine 4
        else 
        setRow "${STATEFULSET_LIST_LC[$line]}" "$rep" "$rep_sq" "否"
        splitLine 4
       fi
    done
    setTable ${table} 

}



# get cpu 
get_cpu_request_diff() {
    table=""
    splitLine 4
    setRow "podname" "运行cpu_repuest" "数据库cpu_repuest" "是否一致"
    splitLine 4
    for (( line=0;line<=${#DEPLOY_LIST[@]};line++ ));
    do
       rep=`kubectl get deployment ${DEPLOY_LIST[$line]} -n tce -o yaml |  egrep cpu:.* | awk -F ':' 'NR==2{print $2}'|grep -o '[0-9]*' `
       rep_sq=`$get_mysql | grep ${DEPLOY_LIST[$line]} | awk '{print $2}'| awk -F ',' '{print$2}' | awk -F ':' '{print $2}' | grep -o '[0-9]*'`
       if [ $rep == $rep_sq ]
        then
        setRow "${DEPLOY_LIST[$line]}" "$rep" "$rep_sq" "是"
        splitLine 4
        else 
        setRow "${DEPLOY_LIST[$line]}" "$rep" "$rep_sq" "否"
        splitLine 4
       fi
    done

    for (( line=0;line<=${#STATEFULSET_LIST_LC[@]};line++ ));
    do
       rep=`kubectl get satefulset ${STATEFULSET_LIST_LC[$line]} -n tce -o yaml |  egrep replicas:.*[0-9]| awk 'NR==2{print $2}'`
       rep_sq=`$get_mysql | grep ${DEPLOY_LIST[$line]} | awk '{print $2}'| awk -F ',' '{print$2}' | awk -F ':' '{print $2}' | grep -o '[0-9]*'`
       if [ $rep == $rep_sq ]
        then
        setRow "${STATEFULSET_LIST_LC[$line]}" "$rep" "$rep_sq" "是"
        splitLine 4
        else 
        setRow "${STATEFULSET_LIST_LC[$line]}" "$rep" "$rep_sq" "否"
        splitLine 4
       fi
    done
    setTable ${table} 
}

get_cpu_limit_diff() {
    table=""
    splitLine 4
    setRow "podname" "运行cpu_limit" "数据库cpu_limit" "是否一致"
    splitLine 4
    for (( line=0;line<=${#DEPLOY_LIST[@]};line++ ));
    do
       rep=`kubectl get deployment ${DEPLOY_LIST[$line]} -n tce -o yaml |  egrep cpu:..* | awk -F ':' 'NR==1{print $2}'|grep -o '[0-9]*' `
       rep_sq=`$get_mysql | grep ${DEPLOY_LIST[$line]} | awk '{print $2}'| awk -F ',' '{print$1}' | awk -F ':' '{print $2}' | grep -o '[0-9]*'`
       if [ $rep == $rep_sq ]
        then
        setRow "${DEPLOY_LIST[$line]}" "$rep" "$rep_sq" "是"
        splitLine 4
        else 
        setRow "${DEPLOY_LIST[$line]}" "$rep" "$rep_sq" "否"
        splitLine 4
       fi
    done

    for (( line=0;line<=${#STATEFULSET_LIST_LC[@]};line++ ));
    do
       rep=`kubectl get satefulset ${STATEFULSET_LIST_LC[$line]} -n tce -o yaml |  egrep cpu:..* | awk -F ':' 'NR==1{print $2}'|grep -o '[0-9]*' `
       rep_sq=`$get_mysql | grep ${STATEFULSET_LIST_LC[$line]} | awk '{print $2}'| awk -F ',' '{print$1}' | awk -F ':' '{print $2}' | grep -o '[0-9]*'`
       if [ $rep == $rep_sq ]
        then
        setRow "${STATEFULSET_LIST_LC[$line]}" "$rep" "$rep_sq" "是"
        splitLine 4
        else 
        setRow "${STATEFULSET_LIST_LC[$line]}" "$rep" "$rep_sq" "否"
        splitLine 4
       fi
    done
    setTable ${table} 
}


# get mem 
get_mem_request_diff() {
    table=""
    splitLine 4
    setRow "podname" "运行mem_request" "数据库mem_request" "是否一致"
    splitLine 4
    for (( line=0;line<=${#DEPLOY_LIST[@]};line++ ));
    do
       rep=`kubectl get deployment ${DEPLOY_LIST[$line]} -n tce -o yaml |  egrep memory:.* | awk -F ':' 'NR==2{print $2}'|grep -o '[0-9]*' `
       rep_sq=`$get_mysql | grep ${DEPLOY_LIST[$line]} | awk '{print $2}'| awk -F ',' '{print$10}' | awk -F ':' '{print $2}' | grep -o '[0-9]*'`
       if [ $rep == $rep_sq ]
        then
        setRow "${DEPLOY_LIST[$line]}" "$rep" "$rep_sq" "是"
        splitLine 4
        else 
        setRow "${DEPLOY_LIST[$line]}" "$rep" "$rep_sq" "否"
        splitLine 4
       fi
    done

    for (( line=0;line<=${#STATEFULSET_LIST_LC[@]};line++ ));
    do
       rep=`kubectl get satefulset ${STATEFULSET_LIST_LC[$line]} -n tce -o yaml |  egrep memory:.* | awk -F ':' 'NR==2{print $2}'|grep -o '[0-9]*' `
       rep_sq=`$get_mysql | grep ${STATEFULSET_LIST_LC[$line]} | awk '{print $2}'| awk -F ',' '{print$10}' | awk -F ':' '{print $2}' | grep -o '[0-9]*'`
       if [ $rep == $rep_sq ]
        then
        setRow "${STATEFULSET_LIST_LC[$line]}" "$rep" "$rep_sq" "是"
        splitLine 4
        else 
        setRow "${STATEFULSET_LIST_LC[$line]}" "$rep" "$rep_sq" "否"
        splitLine 4
       fi
    done
    setTable ${table} 
}
get_mem_limit_diff() {
    table=""
    splitLine 4
    setRow "podname" "运行mem_limit" "数据库mem_limit" "是否一致"
    splitLine 4
    for (( line=0;line<=${#DEPLOY_LIST[@]};line++ ));
    do
       rep=`kubectl get deployment ${DEPLOY_LIST[$line]} -n tce -o yaml |  egrep memory:.* | awk -F ':' 'NR==1{print $2}'|grep -o '[0-9]*' `
       rep_sq=`$get_mysql | grep ${DEPLOY_LIST[$line]} | awk '{print $2}'| awk -F ',' '{print$9}' | awk -F ':' '{print $2}' | grep -o '[0-9]*'`
       if [ $rep == $rep_sq ]
        then
        setRow "${DEPLOY_LIST[$line]}" "$rep" "$rep_sq" "是"
        splitLine 4
        else 
        setRow "${DEPLOY_LIST[$line]}" "$rep" "$rep_sq" "否"
        splitLine 4
       fi
    done

    for (( line=0;line<=${#STATEFULSET_LIST_LC[@]};line++ ));
    do
       rep=`kubectl get satefulset ${STATEFULSET_LIST_LC[$line]} -n tce -o yaml |  egrep memory:.* | awk -F ':' 'NR==1{print $2}'|grep -o '[0-9]*' `
       rep_sq=`$get_mysql | grep ${STATEFULSET_LIST_LC[$line]} | awk '{print $2}'| awk -F ',' '{print$9}' | awk -F ':' '{print $2}' | grep -o '[0-9]*'`
       if [ $rep == $rep_sq ]
        then
        setRow "${STATEFULSET_LIST_LC[$line]}" "$rep" "$rep_sq" "是"
        splitLine 4
        else 
        setRow "${STATEFULSET_LIST_LC[$line]}" "$rep" "$rep_sq" "否"
        splitLine 4
       fi
    done
    setTable ${table} 
}


# get nodeselector 
get_nodeselector_diff() {
     table=""
    splitLine 4
    setRow "podname" "运行nodeselector" "数据库nodeselector" "是否一致"
    splitLine 4
    for (( line=0;line<=${#DEPLOY_LIST[@]};line++ ));
    do
       rep=`kubectl get deployment ${DEPLOY_LIST[$line]} -n tce -o yaml |  egrep -io '"nodeselector":.*'| awk -F '},' '{print $1}' | awk -F 'or":{' '{print $2}'`
       rep_sq=`$get_mysql | grep ${DEPLOY_LIST[$line]}  | awk '{print $2}'| awk -F ',' '{print$13}' | awk -F ':{' '{print $2}' | awk -F '}' '{print $1}'`
       if [ $rep == $rep_sq ]
        then
        setRow "${DEPLOY_LIST[$line]}" "$rep" "$rep_sq" "是"
        splitLine 4
        else 
        setRow "${DEPLOY_LIST[$line]}" "$rep" "$rep_sq" "否"
        splitLine 4
       fi
    done

    for (( line=0;line<=${#STATEFULSET_LIST_LC[@]};line++ ));
    do
       rep=`kubectl get deployment ${STATEFULSET_LIST_LC[$line]} -n tce -o yaml |  egrep -io '"nodeselector":.*'| awk -F '},' '{print $1}' | awk -F 'or":{' '{print $2}'`
       rep_sq=`$get_mysql | grep ${STATEFULSET_LIST_LC[$line]}  | awk '{print $2}'| awk -F ',' '{print$13}' | awk -F ':{' '{print $2}' | awk -F '}' '{print $1}'`
       if [ $rep == $rep_sq ]
        then
        setRow "${STATEFULSET_LIST_LC[$line]}" "$rep" "$rep_sq" "是"
        splitLine 4
        else 
        setRow "${STATEFULSET_LIST_LC[$line]}" "$rep" "$rep_sq" "否"
        splitLine 4
       fi
    done
    setTable ${table} 
}



# get hostnetwork
get_hostnetwork__diff() {
     table=""
    splitLine 4
    setRow "podname" "运行副本数" "数据库中存放的副本数" "是否一致"
    splitLine 4
    for (( line=0;line<=${#DEPLOY_LIST[@]};line++ ));
    do
       rep=`kubectl get deployment ${DEPLOY_LIST[$line]} -n tce -o yaml |  egrep -i hostnetwork:.*| awk '{print $2}'`
       if [ $rep == "true" ]
       then 
         rep=1
       fi
       rep_sq=`$get_mysql | grep ${DEPLOY_LIST[$line]}  |  awk '{print $2}'| awk -F ',' '{print$7}' | awk -F ':"' '{print $2}' | awk -F '"' '{print $1}'`
       if [ $re == $rep_sq ]
        then
        setRow "${DEPLOY_LIST[$line]}" "$rep" "$rep_sq" "是"
        splitLine 4
        else 
        setRow "${DEPLOY_LIST[$line]}" "$rep" "$rep_sq" "否"
        splitLine 4
       fi
    done

    for (( line=0;line<=${#STATEFULSET_LIST_LC[@]};line++ ));
    do
       rep=`kubectl get deployment ${STATEFULSET_LIST_LC[$line]} -n tce -o yaml |  egrep -i hostnetwork:.*| awk '{print $2}'`
       if [ $rep == "true" ]
       then 
         rep=1
       fi
       rep_sq=`$get_mysql | grep ${STATEFULSET_LIST_LC[$line]}  |  awk '{print $2}'| awk -F ',' '{print$7}' | awk -F ':"' '{print $2}' | awk -F '"' '{print $1}'`
       if [ $re == $rep_sq ]
        then
        setRow "${STATEFULSET_LIST_LC[$line]}" "$rep" "$rep_sq" "是"
        splitLine 4
        else 
        setRow "${STATEFULSET_LIST_LC[$line]}" "$rep" "$rep_sq" "否"
        splitLine 4
       fi
    done
    setTable ${table} 
}

get_image_dep_state
get_replicas_diff
get_cpu_request_diff
get_cpu_limit_diff
get_mem_request_diff
get_mem_limit_diff
get_nodeselector_diff
get_hostnetwork__diff
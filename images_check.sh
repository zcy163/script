#!/usr/bin/bash 
################################################################################
#
# 
#
################################################################################
# @Time    : 2022/09/05
# @File    : images_check
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

# 绘制表格
# 入参：table
setTable(){
    echo -e $1|column -s "#" -t|awk '{if($0 ~ /^+/){gsub(" ","-",$0);print $0}else{print $0}}'
}


# functions
# 高亮显示
# red_echo() {
#     echo -e "FAILED:\033[31m$@\033[0m"
# }


# 定义资源清单数组
NS="tce"
DS=(deploy statefulset)
DEPLOY_LIST=()
STATEFULSET_LIST=()
num_dep=0
num_sta=0

# functions
# get deploys/statefulsets
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


# image_deploy_image_list
Array_dep_all=()
# image_statefulset_image_list
Array_state_all=()
# image_deploy_image_list_if：对比后
Array_dep_if=()
# image_statefulset_image_list_if：对比后
Array_state_if=()
# 对比前deploy-state总计
Array_dep_state_all=()
# 对比后deploy-state总计
Array_dep_state_if=()
# 差集
Diff_list=()
num_daif=0
num_saif=0
local_image="/data/tce_dc/software/latest/image/"
# local_image_arry
Array_localimg_all=()
a=0

# get local images
get_local_image() {
    for i in `ls $local_image`;
    do 
        imgage=`echo $i | awk -F '.tar' '{print $1}'`
        Array_localimg_all[$a]=$img
        let a++
    done
}


# functions
# check images deploy
# 分别对比image
check_images_deploy_state() {
    table=""
    splitLine 4
    setRow "podname" "运行版本" "本地存放版本" "是否一致"
    splitLine 4
    get_image_dep_state
    for (( line=1;line<=${#DEPLOY_LIST[@]};line++ ));
    do  
        de_image=`kubectl get deployment ${DEPLOY_LIST[$line]} -n $NS -o yaml |   egrep -i 'image:' | awk '{print $2}' | awk -F '/' '{print $3}'`
        Array_dep_all[$line]=$de_image
        for (( line_lo=1;line_lo<=${#Array_localimg_all[@]};line_lo++ ));
        do
            if [ $de_image == ${Array_localimg_all[$line_lo]} ];
            then 
                Array_dep_if[$num_daif]=$de_image
                let num_daif++
                setRow "${DEPLOY_LIST[$line]}" "$de_image" "${Array_localimg_all[$line_lo]}" "是"
                splitLine 4
                continue
            fi
        done

    done
    for (( line_state=1;line_state<=${#STATEFULSET_LIST[@]};line_state++ ));
    do  
        de_image_state=`kubectl get statefulset ${STATEFULSET_LIST[$line_state]} -n $NS -o yaml |    egrep -i 'image:' | awk '{print $2}' | awk -F '/' '{print $3}'`
        Array_state_all[$line_state]=$de_image_state
        for (( line_st=1;line_st<=${#Array_localimg_all[@]};line_st++ ));
        do
            if [ $de_image_state == ${Array_localimg_all[$line_st]} ];
            then 
                Array_state_if[$num_saif]=$de_image_state
                let num_saif++
                setRow "${STATEFULSET_LIST[$line_state]}" "$de_imag_state" "${Array_localimg_all[$line_st]}" "是"
                splitLine 4
                continue
            fi
        done

    done

# 并集：Array_dep_all + Array_state_all
Array_dep_state_all=(${Array_dep_all[*]}  ${Array_state_all[*]})
# 并集：Array_dep_if + Array_state_if
Array_dep_state_if=(${Array_dep_if[*]}  ${Array_state_if[*]})
# 差集: if差all
Diff_list=(`echo ${Array_dep_state_if[*]} ${Array_dep_state_all[*]}|sed 's/ /\n/g'|sort|uniq -c|awk '$1==1{print $2}'`)
if [[ -n "$Diff_list" ]];
then
    for (( i=0;i<${#Diff_list[@]};i++ ));
    do
	  setRow "${Diff_list[$i]}" "${Diff_list[$i]}" "该镜像在/data/tce_dc/software/latest/image/未找到" "否";
      splitLine 4   
      
    done
fi 
setTable ${table} 
}

get_local_image
check_images_deploy_state
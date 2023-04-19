#!/usr/bin/bash
################################################################################
#
#
#
################################################################################
# @Time    : 2022/09/22
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
    echo -e $*|column -s "#" -t|awk '{if($0 ~ /^+/){gsub(" ","-",$0);print $0}else{print $0}}'
}




# 定义各区IP信息
NH_ZY_IP=10.247.42.68
NH_BZ_IP=10.233.41.81
DXH_03_IP=10.230.32.13
DXH_12_IP=10.227.35.202
DXH_BZ_IP=10.233.41.81
XC_IP=10.229.32.13

# 定义数组
NH_ZY_ZONE=()
NH_BZ_ZONE=()
DXH_03_ZONE=()
DXh_12_ZONE=()
DXH_BZ_ZONE=()
XC_ZONE=()



# functions
# get deploys/statefulsets
get_nh_zy_vpcservice() {
    for i in $(ssh $NH_ZY_IP kubectl get vpcservice  -A | grep -v NAME | awk '{print $1,$2,$3,$4,$5,$6,$7}' | tr ' ' '#');
    do
            NH_ZY_ZONE[$num]=$i
            let num++
    done
}

get_nh_bz_vpcservice() {
    for i in $(ssh $NH_BZ_IP kubectl get vpcservice  -A | grep -v NAME | awk '{print $1,$2,$3,$4,$5,$6,$7}' | tr ' ' '#');
    do
            NH_BZ_ZONE[$num]=$i
            let num++
    done
}

get_dxh_03_vpcservice() {
    for i in $(ssh $DXH_03_IP kubectl get vpcservice  -A | grep -v NAME | awk '{print $1,$2,$3,$4,$5,$6,$7}' | tr ' ' '#');
    do
            DXH_03_ZONE[$num]=$i
            let num++
    done
}

get_dxh_12_vpcservice() {
    for i in $(ssh $DXH_12_IP kubectl get vpcservice  -A | grep -v NAME | awk '{print $1,$2,$3,$4,$5,$6,$7}' | tr ' ' '#');
    do
            DXH_12_ZONE[$num]=$i
            let num++
    done
}

get_dxh_bz_vpcservice() {
    for i in $(ssh $DXH_BZ_IP kubectl get vpcservice  -A | grep -v NAME | awk '{print $1,$2,$3,$4,$5,$6,$7}' | tr ' ' '#');
    do
            DXH_BZ_ZONE[$num]=$i
            let num++
    done
}

get_xc_vpcservice() {
    for i in $(ssh $XC_IP kubectl get vpcservice  -A | grep -v NAME | awk '{print $1,$2,$3,$4,$5,$6,$7}' | tr ' ' '#');
    do
            XC_ZONE[$num]=$i
            let num++
    done
}

get_vpcservice_all() {
    get_nh_zy_vpcservice
    get_nh_bz_vpcservice
    get_dxh_03_vpcservice
    get_dxh_12_vpcservice
    get_dxh_bz_vpcservice
    get_xc_vpcservice
}






# 判断数组的个数
SORT_NUM=()
nh_zy_num=${#NH_ZY_ZONE[@]}
SORT_NUM[0]=$nh_zy_num
nh_bz_num=${#NH_BZ_ZONE[@]}
SORT_NUM[1]=$nh_bz_num
dxh_03_num=${#DXH_03_ZONE[@]}
SORT_NUM[2]=$dxh_03_num
# dxh_12_num=${#DXH_12_ZONE[@]}
# dxh_bz_num=${#DXH_BZ_ZONE[@]}
xc_num=${#XC_ZONE[@]}
SORT_NUM[3]=$xc_num

# 求得最大个数
sort_num(){
  for (( i=1;i<=${#SORT_NUM[@]};i++ ));
   do
    for (( j=0;j<${#SORT_NUM[@]}-$i;j++ ));
      do
        if [ ${SORT_NUM[$j]} -gt ${SORT_NUM[$j+1]} ] ;
        then
        t=${SORT_NUM[$j]}
        SORT_NUM[$j]=${SORT_NUM[$j+1]}
        SORT_NUM[$j+1]=$t
        fi
    done
   done
   list_num=${#SORT_NUM[@]}
   max_num=${SORT_NUM[$list_num-1]}
   echo $max_num
}

print_nh_zy_value(){
    list_num=${#NH_ZY_ZONE[@]}
    max_num=$list_num
    table=""
    splitLine 8
    setRow "ZONE" "NAMESPACES" "NAME" "VPCID" "VPCIP"  "SERVICENAME" "STATUS" "AGE"
    splitLine 8
    for (( i=0;i<$max_num;i++ ));
    do
      column1=$(echo ${NH_ZY_ZONE[$i]}|awk -F '#' '{print $1}')
      column2=$(echo ${NH_ZY_ZONE[$i]}|awk -F '#' '{print $2}')
      column3=$(echo ${NH_ZY_ZONE[$i]}|awk -F '#' '{print $3}')
      column4=$(echo ${NH_ZY_ZONE[$i]}|awk -F '#' '{print $4}')
      column5=$(echo ${NH_ZY_ZONE[$i]}|awk -F '#' '{print $5}')
      column6=$(echo ${NH_ZY_ZONE[$i]}|awk -F '#' '{print $6}')
      column7=$(echo ${NH_ZY_ZONE[$i]}|awk -F '#' '{print $7}')

      setRow "NH_ZY" "$column1" "$column2" "$column3" "$column4" "$column5" "$column6" "$column7"
      splitLine 8
    done
setTable ${table}
}

print_nh_bz_value(){
    list_num=${#NH_BZ_ZONE[@]}
    max_num=$list_num
    table=""
    splitLine 8
    setRow "ZONE" "NAMESPACES" "NAME" "VPCID" "VPCIP"  "SERVICENAME" "STATUS" "AGE"
    splitLine 8
    for (( i=0;i<$max_num;i++ ));
    do
      column1=$(echo ${NH_BZ_ZONE[$i]}|awk -F '#' '{print $1}')
      column2=$(echo ${NH_BZ_ZONE[$i]}|awk -F '#' '{print $2}')
      column3=$(echo ${NH_BZ_ZONE[$i]}|awk -F '#' '{print $3}')
      column4=$(echo ${NH_BZ_ZONE[$i]}|awk -F '#' '{print $4}')
      column5=$(echo ${NH_BZ_ZONE[$i]}|awk -F '#' '{print $5}')
      column6=$(echo ${NH_BZ_ZONE[$i]}|awk -F '#' '{print $6}')
      column7=$(echo ${NH_BZ_ZONE[$i]}|awk -F '#' '{print $7}')

      setRow "NH_BZ" "$column1" "$column2" "$column3" "$column4" "$column5" "$column6" "$column7"
      splitLine 8
    done
setTable ${table}
}

print_dxh_03_value(){
    list_num=${#DXH_03_ZONE[@]}
    max_num=$list_num
    table=""
    splitLine 8
    setRow "ZONE" "NAMESPACES" "NAME" "VPCID" "VPCIP"  "SERVICENAME" "STATUS" "AGE"
    splitLine 8
    for (( i=0;i<$max_num;i++ ));
    do
      column1=$(echo ${DXH_03_ZONE[$i]}|awk -F '#' '{print $1}')
      column2=$(echo ${DXH_03_ZONE[$i]}|awk -F '#' '{print $2}')
      column3=$(echo ${DXH_03_ZONE[$i]}|awk -F '#' '{print $3}')
      column4=$(echo ${DXH_03_ZONE[$i]}|awk -F '#' '{print $4}')
      column5=$(echo ${DXH_03_ZONE[$i]}|awk -F '#' '{print $5}')
      column6=$(echo ${DXH_03_ZONE[$i]}|awk -F '#' '{print $6}')
      column7=$(echo ${DXH_03_ZONE[$i]}|awk -F '#' '{print $7}')

      setRow "DXH_03" "$column1" "$column2" "$column3" "$column4" "$column5" "$column6" "$column7"
      splitLine 8
    done
setTable ${table}
}

print_dxh_12_value(){
    list_num=${#DXH_12_ZONE[@]}
    max_num=$list_num
    table=""
    splitLine 8
    setRow "ZONE" "NAMESPACES" "NAME" "VPCID" "VPCIP"  "SERVICENAME" "STATUS" "AGE"
    splitLine 8
    for (( i=0;i<$max_num;i++ ));
    do
      column1=$(echo ${DXH_12_ZONE[$i]}|awk -F '#' '{print $1}')
      column2=$(echo ${DXH_12_ZONE[$i]}|awk -F '#' '{print $2}')
      column3=$(echo ${DXH_12_ZONE[$i]}|awk -F '#' '{print $3}')
      column4=$(echo ${DXH_12_ZONE[$i]}|awk -F '#' '{print $4}')
      column5=$(echo ${DXH_12_ZONE[$i]}|awk -F '#' '{print $5}')
      column6=$(echo ${DXH_12_ZONE[$i]}|awk -F '#' '{print $6}')
      column7=$(echo ${DXH_12_ZONE[$i]}|awk -F '#' '{print $7}')

      setRow "DXH_12" "$column1" "$column2" "$column3" "$column4" "$column5" "$column6" "$column7"
      splitLine 8
    done
setTable ${table}
}

print_dxh_bz_value(){
    list_num=${#DXH_BZ_ZONE[@]}
    max_num=$list_num
    table=""
    splitLine 8
    splitLine 8
    echo $(echo ${DXH_BZ_ZONE[2]}|awk -F '#' '{print $1}')
    for (( i=0;i<$max_num;i++ ));
    do
      column1=$(echo ${DXH_BZ_ZONE[$i]}|awk -F '#' '{print $1}')
      column2=$(echo ${DXH_BZ_ZONE[$i]}|awk -F '#' '{print $2}')
      column3=$(echo ${DXH_BZ_ZONE[$i]}|awk -F '#' '{print $3}')
      column4=$(echo ${DXH_BZ_ZONE[$i]}|awk -F '#' '{print $4}')
      column5=$(echo ${DXH_BZ_ZONE[$i]}|awk -F '#' '{print $5}')
      column6=$(echo ${DXH_BZ_ZONE[$i]}|awk -F '#' '{print $6}')
      column7=$(echo ${DXH_BZ_ZONE[$i]}|awk -F '#' '{print $7}')

      setRow "NH_ZY" "$column1" "$column2" "$column3" "$column4" "$column5" "$column6" "$column7"
      splitLine 8
    done
setTable ${table}
}

print_xc_value(){
    list_num=${#XC_ZONE[@]}
    max_num=$list_num
    table=""
    splitLine 8
    setRow "ZONE" "NAMESPACES" "NAME" "VPCID" "VPCIP"  "SERVICENAME" "STATUS" "AGE"
    splitLine 8
    for (( i=0;i<$max_num;i++ ));
    do
      column1=$(echo ${XC_ZONE[$i]}|awk -F '#' '{print $1}')
      column2=$(echo ${XC_ZONE[$i]}|awk -F '#' '{print $2}')
      column3=$(echo ${XC_ZONE[$i]}|awk -F '#' '{print $3}')
      column4=$(echo ${XC_ZONE[$i]}|awk -F '#' '{print $4}')
      column5=$(echo ${XC_ZONE[$i]}|awk -F '#' '{print $5}')
      column6=$(echo ${XC_ZONE[$i]}|awk -F '#' '{print $6}')
      column7=$(echo ${XC_ZONE[$i]}|awk -F '#' '{print $7}')

      setRow "NH_ZY" "$column1" "$column2" "$column3" "$column4" "$column5" "$column6" "$column7"
      splitLine 8
    done
setTable ${table}
}
get_vpcservice_all
result_dir=./result_dir
if [  -d $result_dir ] ;then
print_nh_zy_value > ./result_dir/res_table.csv
print_nh_bz_value >> ./result_dir/res_table.csv
print_dxh_03_value >> ./result_dir/res_table.csv
print_dxh_12_value >> ./result_dir/res_table.csv
print_dxh_bz_value >> ./result_dir/res_table.csv
print_xc_value
else 
mkdir $result_dir
print_nh_zy_value > ./result_dir/res_table.csv
print_nh_bz_value >> ./result_dir/res_table.csv
print_dxh_03_value >> ./result_dir/res_table.csv
print_dxh_12_value >> ./result_dir/res_table.csv
print_dxh_bz_value >> ./result_dir/res_table.csv
print_xc_value >> ./result_dir/res_table.csv
fi

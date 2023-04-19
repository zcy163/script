# -*- coding: utf-8 -*-

"""
    json_yaml_diff
"""
import os
import sys
import json
import yaml
import json_tools
import openpyxl 

class Get_Diff_Json_Yaml():

    def __init__(self):
        self.result = ''
        self.file1 = ''
        self.file2 = ''
        self.root1 = ''
        self.root2 = ''
        self.fi = ''

    def json_if_yaml(self,file1,file2):
        self.file1 = file1
        self.file2 = file2
        if self.file1.endswith('.json') == self.file2.endswith('.json'):
            if(self.file1.endswith('.json')):
                self.result = self.diff_json(file1,file2)
            elif self.file1.endswith('.yaml') == self.file2.endswith('.yaml'):
                if(self.file2.endswith('.yaml')):
                    self.result = self.diff_yaml(file1,file2)
        else:
            print("文件后缀名不一致，停止比对。")
            sys.exit()
        return self.result
    
    def get_dir_files(self,dir1,dir2):
        file_paths = []
        file_paths1 = []
        oam_list = []
        for root, ds, fs in os.walk(dir1):
            for item in fs:
                if(item.endswith('.json')):
                    file_paths.append(item)
                if(item.endswith('.yaml')):
                    file_paths.append(item)
        self.root1 = root
        for root, ds, fs in os.walk(dir2):
            for item in fs:
                if(item.endswith('.json')):
                    file_paths1.append(item)
                if(item.endswith('.yaml')):
                    file_paths1.append(item)
        self.root2 = root
        for oam in file_paths:
            oam_path = oam.split(".")[0] + '.' + 'oam' + '.' + oam.split(".")[-1]
            oam_list.append(oam_path)
        return file_paths, oam_list
    
    def get_dir_diff_print(self,list):
        for i  in (range(len(list[0]))):
            f1 = self.root1 + '\\'  + list[0][i]
            f2 = self.root2 + '\\' + list[1][i]
            pr = self.json_if_yaml(f1,f2)
            self.result_print(pr)

    def get_dir_diff_txt(self,list,path="./"):
        for i  in (range(len(list[0]))):
            f1 = self.root1 + '\\'  + list[0][i]
            f2 = self.root2 + '\\' + list[1][i]
            pr = self.json_if_yaml(f1,f2)
            self.result_txt(pr,path)

    def get_dir_diff_table(self,list,path="./"):
        for i  in (range(len(list[0]))):
            f1 = self.root1 + '\\'  + list[0][i]
            f2 = self.root2 + '\\' + list[1][i]
            pr = self.json_if_yaml(f1,f2)
            self.result_table(pr,path)
  
    def get_yaml(self,yaml_file):
        with open(yaml_file, "r+", encoding="utf-8") as f:
           yaml_0 = yaml.safe_load(stream=f.read(),Loader=yaml.SafeLoader)
        #    yaml_0 = yaml.load_all(f,Loader=yaml.FullLoader)
        #    yaml_0 = yaml.load_all(f, Loader=yaml.SafeLoader)   # -- -
        #    for di in yaml_0:
        #         print(di)
        return yaml_0  

    def get_json(self,json_file):
        yaml_0 = json.load(open(json_file,'r',encoding="utf-8"))
        return yaml_0  

    def diff_json(self,file1,file2):
        self.fi = ''
        diffjson = json_tools.diff(self.get_json(file1),self.get_json(file2))
        if diffjson:
            pass
        else:
            self.fi = 'json文件对比无差异'
        return diffjson

    def diff_yaml(self,file1,file2):
        self.fi = ''
        diffyml = json_tools.diff(self.get_yaml(file1),self.get_yaml(file2))
        if diffyml:
            pass
        else:
            self.fi = 'yaml文件对比无差异'
        return diffyml
    
    def result_print(self,result):
        print("对比的第一个yaml文件名：" + str(self.file1))
        print("对比的第二个yaml文件名：" + str(self.file2))
        print(self.fi)
        for i in result:
            for key in i: 
                # print(key,":",i[key])
                if key == "remove":
                    print("第二个文件对比第一个文件，缺少的key值：  " + str(i[key]))
                if key == "add":
                    print("第二个文件对比第一个文件，多出的key值：  " + str(i[key]))
                if key == "replace":
                    print("第二个文件对比第一个文件，有差异的key值：  " + str(i[key]))
                if key == "value":
                    print("该key对应的第二个文件中的value值：  " + str(i[key]))
                if key == "prev":
                    print("该key对应的第一个文件中的value值：  " + str(i[key]) + '\n' )

    def result_txt(self,result,path):
        with open(path + self.file1.split(".")[1] + self.file1.split(".")[0].split("\\")[-1],"a+", encoding='UTF-8')as of:
            of.writelines(self.fi + '\n' )
            of.writelines("比对的文件：     (1)" + self.file1 + "     (2)" + self.file2  + '\n' )           
            for i in result:
                for key in i: 
                    if key == "remove":
                        of.writelines( '\n' )
                        of.writelines("第二个文件对比第一个文件，缺少的key值：  " + str(i[key]) + '\n' )
                    if key == "add":
                        of.writelines( '\n' )
                        of.writelines("第二个文件对比第一个文件，多出的key值：  " + str(i[key]) + '\n' )
                    if key == "replace":
                        of.writelines( '\n' )
                        of.writelines("第二个文件对比第一个文件，有差异的key值：  " + str(i[key]) + '\n' )
                    if key == "value":
                        of.writelines("该key对应的第二个文件中的value值：  " + str(i[key]) + '\n' )
                    if key == "prev":
                        of.writelines("该key对应的第一个文件中的value值：  " + str(i[key]) + '\n' )
                        
            of.close

    def result_table(self,result,path):
        workbook = openpyxl.Workbook()
        sheet = workbook.active
        sheet.title = "openpyxl"
        sheet.append(["比对的文件：     (1)" + self.file1 + "     (2)" + self.file2 ])
        sheet.append(["有差异的key", "key对应第一个文件的value值", "key对应第二个文件的value值"])
        sheet.append([self.fi])
        for data in result:
            sheet.append(list(data.values())) 
        workbook.save(path + self.file1.split(".")[1] + self.file1.split(".")[0].split("\\")[-1]  + ".xlsx")



if __name__ == "__main__":
    # 初始化实例
    ymjsd = Get_Diff_Json_Yaml()

    # json 单个文件对比
    json_file1='./1.json'
    json_file2='./1.json'
    res = ymjsd.json_if_yaml(json_file1,json_file2)
    ymjsd.result_print(res) # 对比结果打印
    ymjsd.result_txt(res) # 对比结果保存txt,可传path参数
    ymjsd.result_table(res) # 对比结果保存excel,可传path参数

    # json 批量对比，指定目录
    json_dir1= './json1'
    json_dir2= './json2'
    lis = ymjsd.get_dir_files(json_dir1,json_dir2)
    res = ymjsd.get_dir_diff_txt(lis) # 对比结果保存txt
    res = ymjsd.get_dir_diff_table(lis) # 对比结果保存excel

    path = '/root/home/1'  # 路径可选参数，默认./
    res = ymjsd.get_dir_diff_txt(lis,path) # 对比结果保存txt
    res = ymjsd.get_dir_diff_table(lis,path) # 对比结果保存excel


    # yaml 单个文件对比
    yaml_file1='./1.yaml'
    yaml_file2='./1.yaml'
    res = ymjsd.json_if_yaml(yaml_file1,yaml_file2)
    ymjsd.result_print(res) # 对比结果打印
    ymjsd.result_txt(res) # 对比结果保存txt,可传path参数

    # yaml 批量对比，指定目录
    yaml_dir1= './yaml1'
    yaml_dir2= './yaml2'
    lis = ymjsd.get_dir_files(yaml_dir1,yaml_dir2)
    res = ymjsd.get_dir_diff_txt(lis) # 对比结果保存txt,可传path参数

    path = '/root/home/1'  # 路径可选参数，默认./
    res = ymjsd.get_dir_diff_txt(lis,path) # 对比结果保存txt
    res = ymjsd.get_dir_diff_table(lis,path) # 对比结果保存excel


        
#!/usr/bin/env python3

import os
import csv

# 读取以 \t 分割每行，这是为了防止文件名出现逗号
csv_reader = csv.reader(open("duplicate_file.csv", encoding='utf-16'), delimiter='\t')

last_file_size = ""
last_file_name = ""

def beauti_file_name(file_name):
	return file_name.replace("\n", "").replace("\"", "")

is_head = True
success_index = 0
fail_index = 0
ready_to_delete = []

# 预览一次
for row in csv_reader:
	if is_head == True:
		# 跳过页头
		is_head = False
		continue
	
	# 分割，先加 \t 再切割，防止文件名出现逗号
	rows_split = '\t'.join(row).split("\t")
	print(rows_split)
	
	current_file_size = rows_split[3]
	current_file_name = rows_split[2]

	if current_file_size == last_file_size:
		print("准备删除:" + current_file_name + " " + current_file_size)
		print("因为它和:" + last_file_name + " " + last_file_size + "一样")
		ready_to_delete.append(current_file_name)
		
	last_file_size = rows_split[3]
	last_file_name = rows_split[2]
	
choose = input("确定开始删除吗？回复 Y = 确认，N = 取消，输入完按回车：")

if "Y" or "y" in choose:
	# 跑一次
	for file in ready_to_delete:
		try:
			os.remove(file)
			print("{} 被成功删除了".format(file))
			success_index = success_index + 1
		except FileNotFoundError:
			fail_index = fail_index + 1
			print("没找到这个文件")
		print(" ")
	print("一共成功删除了 {} 个文件，失败了 {} 个".format(success_index, fail_index))
else:
	print("已取消～")
	


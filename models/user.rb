# -*- coding:utf-8 -*- 
require './lib'
fix187_in_window10
require './db'

class User < DB
	def get(user_name) 
		data = dict("select id,user_name,password from info_user where user_name=?", [user_name])
		return data
	end
	def exist(name)
		return first("select count(*) from info_user where user_name =?", [name]) != 0
	end
	def save(name, password)
		execute("insert into info_user(user_name,password,create_time)values(?,?,datetime('now','localtime'))", [name, password])
	end
end


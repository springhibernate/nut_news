# -*- coding:utf-8 -*- 
require 'lib'
fix187_in_window10

require 'sqlite3'
require 'json'
require 'sinatra'
require 'sinatra/reloader'

require 'models/collect'
require 'models/comment'
require 'models/info'
require 'models/user'

=begin
cd to nut_new and cmd: ruby index.rb
open browse and input: http://localhost:4567
=end 

enable :sessions

before do 
	content_type :json, 'charset' => 'utf-8' if request.path_info.start_with?("/info/")
end

def resp(dict)
	return [200,{"Access-Control-Allow-Origin"=>"*","Access-Control-Allow-Methods"=>"GET","Access-Control-Allow-Headers"=>"x-requested-with,content-type"},dict.to_json]
end

get '/' do 
	erb :info
end

get '/info/list' do
	dataList,totalPages=Info.new.paginate(params['page'])
	res={:dataList=>dataList,:totalPages=>totalPages}
	resp res
end

get '/info/detail' do 
	id = params['id']
	data=Info.new.detail(id)
    resp data
end

get '/info/comment_list' do 
	info_id = params['info_id']
	dataList,totalPages=Comment.new.paginate(params['page'],info_id)
	res={:dataList=>dataList,:totalPages=>totalPages}
	resp res
end

get '/info/collection' do 
	user_id = session['user_id']
	dataList,totalPages=Collect.new.paginate(params['page'],user_id)
	res={:dataList=>dataList,:totalPages=>totalPages}
	resp res
end

get '/info/collect' do 
	res={}
	if session["user_id"] == nil
		res[:status] = 0
		res[:message] = "Login first"
	else 
		user_id = session["user_id"]
		info_id = params["info_id"]
		Collect.new.collect(user_id,info_id)
		res[:status] = 1
		res[:message] = "Collect successfully"
	end
	resp res
end

get '/info/collected' do 
	res = {}
	if session["user_id"] == nil
		res[:status] = 0
	else
		user_id = session["user_id"]
		info_id = params["info_id"]
		if not Collect.new.exist(user_id,info_id)
			res[:status] = 0
		else 
			res[:status] = 1
		end
	end
	resp res
end

get '/info/logined' do 
	res={}
	if session["user_id"] == nil
		res[:status] = 0
	else
		res[:status] = 1
		res[:message] = session["user_name"]
	end
	resp res
end

post '/info/login' do 
	#TODO remeber password
	#TODO refine the length of user_name
	#TODO refine the length of password
	#TODO encrypt password 
	name = params["name"]
	password = params["password"]
	
	data = User.new.get(name)
	res={}
	if data == nil or data["password"] != password
		res[:status] = 0
		res[:message] = "Name or Password not correct"
	else
		res[:status] = 1
		res[:message] = "Login Successfully"
		session["user_id"] = data["id"]
		session["user_name"] = data["user_name"]
	end
	resp res
end

get '/info/logout' do 
	session["user_id"] = nil
    session["user_name"] = nil
    res={}
	res[:status] = 0
	res[:message] = "Logout successfully"
    resp res
end

post '/info/register' do 
	name = params["name"]
    password = params["password"]
    res={}
	user=User.new
	if not user.exist(name)
		#TODO encrypt password
		user.save(name, password)
		res[:status] = 1
		res[:message] = "register successfully"
		data = user.get(name)
		session["user_id"] = data["id"]
	else
		res[:status] = 0
		res[:message] = "the Name already use,try others"
	end
	resp res
end

post '/info/comment_save' do 
	info_id = params["info_id"]
	content = params["content"]
	user_id = session["user_id"]
	res={}
	Comment.new.save(info_id, user_id,content)
	res[:status] = 1
	res[:message] = "comment successfully"
	resp res
end

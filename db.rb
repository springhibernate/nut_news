# -*- coding:utf-8 -*- 

require 'lib'
fix187_in_window10
require 'sqlite3'

class DB
	attr_accessor :db
	def initialize()
		@db = SQLite3::Database.new( "db" )
		init
	end
	
	def first(sql,param_arr=nil)
		return execute(sql,param_arr)[0][0]
	end

	def dict(sql,param_arr=nil)
		return list(sql,param_arr)[0]
	end

	def page(page_cur,sql,param_arr=nil)
		page_size = 10
		count = first("select count(*) from (#{sql})",param_arr)
		totalPages = count / page_size;
		totalPages = totalPages + 1 if count % page_size != 0
		page_index = (page_cur.to_i - 1) * page_size
		sql = "#{sql} limit #{page_size} offset #{page_index}"
		return [list(sql,param_arr),totalPages]
	end

	def list(sql,param_arr=nil)
		db.results_as_hash = true
		rlt=execute(sql,param_arr)
		return rlt
	end
	
	def execute(sql,param_arr=nil)
		if not param_arr
			return db.execute(sql)
		else
			return db.execute(sql,param_arr)
		end
	end

	def close
		db.close
	end

	def init()
		schema=%{
create table if not exists info_cat(
id integer primary key autoincrement,
cat_name nvarchar(500),
cat_color nvarchar(500)
);
create table if not exists info_info(
id integer primary key autoincrement,
picture nvarchar(500),
title nvarchar(500),
author nvarchar(500),
content text,
cat_id integer,
create_time datetime,
read_count integer
);
create table if not exists info_user(
id integer primary key autoincrement,
user_name nvarchar(500),
password nvarchar(500),
create_time datetime
);
create table if not exists info_collect(
id integer primary key autoincrement,
user_id integer,
info_id integer,
create_time datetime
);
create table if not exists info_comment(
id integer primary key autoincrement,
user_id integer,
info_id integer,
content nvarchar(4000),
create_time datetime
);
		}
		arr=schema.split(";")
		arr.each do |a|
			db.execute(a) if not a.strip.empty?
		end
		
		add_cat_if("Politics", "stable-dark")
        add_cat_if("Business","dark")
        add_cat_if("Health","balanced")
        add_cat_if("Sports", "energized")
        add_cat_if("Technology", "positive")
        add_cat_if("Science","calm")
        add_cat_if("Entertainment","royal")

		init_info()
		
		add_user_if("John", "123456")
        add_user_if("Lilly", "123456")
        add_user_if("David", "123456")

        add_comment_if("it is amazing","John")
        add_comment_if("it is great","Lilly")
        add_comment_if("what is it","David")

        
	end

	def add_user_if(name,password)		
		cnt = first("select count(*) from info_user where user_name=?", [name])
        if cnt == 0
            execute("insert into info_user(user_name,password)values(?,?)", [name,password])
        end
	end

	def add_comment_if(content,name)
		user_id = first("select count(*) from info_user where user_name=?", [name])
		info_id= first("select id from info_info order by create_time desc")
		cnt = first("select count(*) from info_comment where info_id=?", [info_id])
        if cnt < 3
            execute("insert into info_comment(user_id,info_id,content,create_time)values(?,?,?,datetime('now','localtime'))", [user_id,info_id,content])
        end
	end

    def add_cat_if(cat_name,cat_color)
        cnt = first("select count(*) from info_cat where cat_name=?", [cat_name])
        if cnt == 0
            execute("insert into info_cat(cat_name,cat_color)values(?,?)", [cat_name,cat_color])
        end
    end
    
	def init_info()
		pic_dir="public/info/"
		Dir.foreach(pic_dir) do |entry|
			path=pic_dir+entry
			if path.end_with?(".txt")
				lines=File.readlines(path)
				title = lines[0].strip.gsub("'","")
                cat = lines[1].strip
                author = lines[2].strip
                picture = lines[3].strip
                content = lines[4..(lines.size-1)].join("<br/>")
				content=content.strip.gsub("'","")
				cat_id=get_cat_id(cat)
                add_info_if(title, cat_id, author, picture, content)
			end
		end
		
        cnt = first("select count(*) from info_info")
        if cnt < 10
            info= dict("select title,author,picture,content from info_info order by id desc limit 1");
            cat_id=get_cat_id("Entertainment")
			(1..100).each do |i|
				add_info_if(info["title"] + i.to_s,cat_id , info["author"], info["picture"], info["content"]);
            end
        end
	end

    def get_cat_id(cat_name)
        return first("select id from info_cat where cat_name=?", [cat_name])
    end
    
	def add_info_if(title,cat_id,author,picture,content)
        cnt = first("select count(*) from info_info where title=?", [title])
        if cnt == 0
            execute("insert into info_info(title,cat_id,author,picture,content,create_time,read_count)values(?,?,?,?,?,datetime('now','localtime'),0)", [title,cat_id , author, picture, content])
        end
    end
end

# -*- coding:utf-8 -*- 

#fix the problem of ruby187 in windows10:not load the gem which under C:/Ruby187/lib/ruby/gems/1.8/gems/
#这段代码是修复require can not load file sqlite3的问题
#这个问题估计是ruby187在windows10下的bug：$LOAD_PATH默认没有加载C:/Ruby187/lib/ruby/gems/1.8/gems/下的所有gem包
#注意路径是C:/Ruby187/lib/ruby/gems/,不是C:\Ruby187\lib\ruby\gems\
def fix187_in_window10
	lib_path="C:/Ruby187/lib/ruby/gems/1.8/gems/"
	Dir.foreach(lib_path) do |entry|
		if entry=="." or entry ==".."
			next
		end
		path=lib_path+entry+"/lib"
		$LOAD_PATH.unshift path
	end
end

def handle_picture(picture)
	return "/info/"+picture
end

def handle_create_time(create_time)
	c=Time.parse(create_time)
	c_ydm= Time.local(c.year,c.month,c.day,0,0,0 )
	n=Time.now
	n_ydm=Time.local(n.year,n.month,n.day,0,0,0 )
	interval= n_ydm-c_ydm
	if interval==0.0
		return "today";
	elsif interval==60*60*24
		return "yesterday"
	else
		return c_ydm.strftime("%Y-%m-%d")
	end
end
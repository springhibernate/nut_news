# -*- coding:utf-8 -*- 
require './lib'
fix187_in_window10
require './db'

class Collect < DB
	def paginate(page_cur,user_id)
		sql = %Q{select i.title,i.create_time,c.info_id from info_collect c 
left join info_info i  on i.id=c.info_id
where c.user_id=?
order by c.create_time desc}
		dataList,totalPages = page(page_cur,sql,[user_id])
		dataList.each do |data| 
			data["create_time"] = handle_create_time(data["create_time"])
		end
		return [dataList,totalPages]
	end
	def collect(user_id, info_id)
		if not exist(user_id, info_id)
			execute("insert into info_collect(user_id,info_id,create_time)values(?,?,datetime('now','localtime'))", [user_id, info_id])
		end
	end
	def exist(user_id, info_id)
		return first("select count(*) from info_collect where user_id=? and info_id=?", [user_id, info_id]) != 0
	end
end


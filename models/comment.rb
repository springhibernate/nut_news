# -*- coding:utf-8 -*- 
require './lib'
fix187_in_window10
require './db'

class Comment < DB
	def paginate(page_cur,info_id)
		sql = %Q{select u.user_name,c.content,c.create_time from info_comment c 
left join info_user u on c.user_id=u.id
where c.info_id=?
order by c.create_time desc
		}
		dataList,totalPages = page(page_cur,sql,[info_id])
		dataList.each do |data| 
			data["create_time"] = handle_create_time(data["create_time"])
		end
		return [dataList,totalPages]
	end
	def save(info_id, user_id,content)
		execute("insert into info_comment(info_id,user_id,content,create_time)values(@info_id,@user_id,@content,datetime('now','localtime'))", [info_id, user_id,content])
	end
end


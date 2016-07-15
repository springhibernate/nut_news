# -*- coding:utf-8 -*- 
require './lib'
fix187_in_window10
require './db'

class Info < DB
	def paginate(page_cur)
		sql = %Q{select c.cat_name,c.cat_color,i.id,i.title,i.create_time,i.author,i.picture from info_info i 
		left join info_cat c on i.cat_id=c.id
		order by i.create_time desc
		}
		dataList,totalPages = page(page_cur, sql)
		dataList.each do |data|
			data["picture"] = handle_picture(data["picture"])
			data["create_time"] = handle_create_time(data["create_time"])
		end
		return [dataList,totalPages]
	end
	def detail(id)
		execute("update info_info set read_count=read_count+1 where id=?", [id])
		data = dict("select i.* from info_info i where i.id=?", [id])
		data["picture"] = handle_picture(data["picture"])
		data["create_time"] = handle_create_time(data["create_time"])
		return data
	end
end


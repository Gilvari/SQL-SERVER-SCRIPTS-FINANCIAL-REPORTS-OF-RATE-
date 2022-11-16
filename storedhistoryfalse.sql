select top 50 c.Id, * from AST_StoredHistory sh
join ACC_AccDoc d on d.Id=sh.docid
join ACC_AccDocRow dr on dr.DId=d.id
join AST_Card c on c.Id=sh.CardId
	where c.Id in (202983,202920,202946) and  d.DocType=10
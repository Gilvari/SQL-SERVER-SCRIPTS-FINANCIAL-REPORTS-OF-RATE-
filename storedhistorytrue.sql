select top 50 c.Id, * from AST_StoredHistory sh
join ACC_AccDocRow dr on dr.Id=sh.DocRowId
join ACC_AccDoc d on d.Id=dr.DId
join AST_Card c on c.Id=sh.CardId

where c.Id in (202983,202920,202946) and  d.DocType=10
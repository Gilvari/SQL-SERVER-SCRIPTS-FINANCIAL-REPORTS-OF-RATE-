
select dr.T2Id,*
from AST_Card c
--join AST_StoredHistory sh on c.Id = sh.CardId
join STK_GoodsImportRow ir on  ir.Id = c.DirectImpExpRowId
join ACC_AccDocRow dr on dr.Id = ir.DocRowId



BEGIN TRY
	BEGIN TRAN


	declare @stockid int, @t3Id int,@goodid int;
	select @goodid=id
	from stk_goods
	where code='101090900927'
	select @goodid
	
	select * 
	from STK_Stock s 
	join ACC_T1 t1 on s.t1Id=t1.Id 
	join M_ORG_T3 t3 on t1.T3Id=t3.id
	where t1.code='7-1' and t3.code='131212'
	
	select @stockid=s.id,@t3Id=t3.id
	from STK_Stock s 
	join ACC_T1 t1 on s.t1Id=t1.Id 
	join M_ORG_T3 t3 on t1.T3Id=t3.id
	where t1.code='7-1' and t3.code='131212'
	
	DECLARE @tbl table(Goodsid int, Quantity decimal)
	
	--INSERT INTO @tbl




	select t.goodId as goodId,
		round(SUM(t.sum_Import), 0, 10) as sum_Import,
		round(SUM(t.reamain_import), 0, 10) as remain_import,
		round(SUM(t.directQuan + t.sum_export), 0, 10) as sum_export, 		
		round(SUM(t.remain_export), 0, 10) as remain_export, 
		
		round(SUM(t.ImportRemainQty), 0, 10) as ImportRemainQty, 
		
		
		round(SUM(t.sum_Import - t.directQuan - t.sum_export), 0, 10) as  sum_Dif,
		round(SUM(t.reamain_import - t.remain_export), 0, 10) as remain_Dif, 
		
		round(SUM(t.directQuan), 0, 10) as directQuan,
		round(SUM(t.IsRemains), 0, 10) as IsRemains
	into #tt
	from
	(
	select 
		r.GoodsId as goodId,
		SUM(r.Quantity) as sum_Import, 
		SUM(RemainQty) as ImportRemainQty, 
		SUM(convert(int, IsRemains)) as IsRemains,
		SUM( case when i.ImportKindIndex IN (14, 15) then Quantity else 0 end) as directQuan,
		0 as sum_export ,
		0 as reamain_import,
		0 as remain_export
	from STK_GoodsImportRow r
	join STK_GoodsImport i on i.Id = r.GoodsImportId
	where i.StockId = @stockid and i.Serial > 0
	and r.GoodsId =@goodid
	group by r.GoodsId
	
	union
	
	select 
		r.GoodsId as goodId,
		0 as sum_Import,
		0 as ImportRemainQty,
		0 as IsRemains,
		0 as directQuan,
		SUM(r.Quantity) as sum_export,
		0 as reamain_import,
		0 as remain_export
	from STK_GoodsExportRow r
	join STK_GoodsExport i on i.Id = r.GoodsExportId
	where i.StockId = @stockid and i.Serial > 0
	and r.GoodsId=@goodid
	group by r.GoodsId 
	
	union
	
	select 
		GoodsId as goodId,
		0 as sum_Import,
		0 as ImportRemainQty,
		0 as IsRemains,
		0 as directQuan,
		0 as sum_export,
		sum(Imports) as reamain_import,
		sum(Exports) as remain_export
	from STK_RemainArticles r
	where StockId = @stockid
	and r.GoodsId =@goodid
	group by r.GoodsId
	
	)t
	group by t.goodId
	
	
	select * from #tt
	
	select ImportRemainQty - t.sum_Dif, t.* 
	from #tt t
	where 
		sum_Import <> remain_import
		or
		sum_export <> remain_export
		or
		sum_Dif <> ImportRemainQty
		or
		remain_Dif <> ImportRemainQty


	
select i.Serial,i.ImportKindIndex,er.id,er.Quantity,IsRemains,RemainQty
from STK_GoodsImportRow er
join STK_GoodsImport i on er.GoodsImportId=i.id
where GoodsId=@goodid and i.Serial>0 and StockId=@stockid
order by i.Serial


select *--i.Serial,i.ImportKindIndex,er.id,er.Quantity,IsRemains,RemainQty
from STK_GoodsImportRow ir
join STK_GoodsImport i on ir.GoodsImportId=i.id
left join STK_ExportRow_ImportRow eir on ir.id=eir.ImportRowId
left join STK_GoodsExportRow er on eir.ExportRowId=er.id
left join STK_GoodsExport e on er.GoodsExportId=e.id
where ir.GoodsId=@goodid and i.Serial>0 and i.StockId=@stockid
order by i.Serial



--select * from STK_GoodsImportRow where id=395651
--update STK_GoodsImportRow set IsRemains=1,RemainQty=6 where id=395651
--select * from STK_GoodsImportRow where id=395651



--exec USP_STK_SAVE_SET_EXPSERIAL @EXPId=276424,@UserId=5277--,@SelectAndReturn=1
--exec USP_STK_SAVE_SET_EXPSERIAL @EXPId=272190,@UserId=5277--,@SelectAndReturn=1





	rollback TRAN
	--drop table #tt
END TRY
BEGIN CATCH
	PRINT ERROR_MESSAGE();
	ROLLBACK TRAN
END CATCH

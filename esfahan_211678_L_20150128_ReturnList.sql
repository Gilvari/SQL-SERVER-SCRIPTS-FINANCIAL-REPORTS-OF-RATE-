
DECLARE @userid AS INT,@t3id AS int
SELECT @t3id = t3id FROM dbo.STK_GoodsImport
WHERE id=197681
SELECT @userid=MIN(id)
FROM dbo.ORG_Personnel 
WHERE T3Id=@t3id
BEGIN TRY
BEGIN TRAN

INSERT INTO [dbo].[STK_ReturnsEIList]
   ([EIId]
   ,[Quantity]
   ,[IRId])
SELECT
	EI.[Id] AS [EIId]
   ,EI.[Quantity] AS [Quantity]
   ,IR_Ret.Id AS  [IRId]
FROM STK_GoodsImportRow IR_Ret
Inner JOIN STK_GoodsImport I_Ret On I_Ret.Id = IR_Ret.GoodsImportId
Inner JOIN STK_ExportRow_ImportRow EI ON
 IR_Ret.MainEditExportRowId = EI.ExportRowId
WHERE I_Ret.ImportKindIndex = 7 
AND IR_Ret.Id NOT IN (SELECT IRID FROM dbo.STK_ReturnsEIList)
AND IR_Ret.GoodsImportId=197681

EXEC dbo.USP_STK_SAVE_IMPORTDOC 
@id=197681,@t3id=@t3id,@userid=@userid,@activeyear=93,
@SelectAndReturn=1

SELECT doc.* FROM dbo.STK_GoodsImport I
INNER JOIN dbo.ACC_AccDoc doc
ON i.AccDocId=doc.Id
WHERE i.id=197681

/*
Id	T3Id	T3IdOrg	DocType	Detail	ExternalNote	ExternalId	Date	AuditorId	DocNo	DaybookNo	NDocNo	NDaybookNo	PrinterId	PrintDate	Finishd	SendForT3owner	DocIdAtOrg	RejectedByAouditor	RejectDetail	DafUserId	DafOKDate	State	Year	UserDate	QuanOfAttached	ControlCode	T2FlgDate	T2Flg	IsIndependent	ExportId	ImportId	ControlCodeInt	Candel
1102384	295881	295881	6	”‰œ ”Ì” „Ì »—«Ì —”Ìœ ‘„«—Â: 113 ‘‰«”Â: 197681 || „—ÃÊ⁄Ì 110-93		197681	2015-02-01 14:57:23.030	298	0	0	0	0	298	2015-02-01 14:57:23.030	0	0	NULL	0		NULL	NULL	1	93	2014-09-11 00:00:00.000	0		2015-02-01 14:57:23.187	0	NULL	NULL	NULL	0	1
*/


commit TRAN
END TRY
BEGIN CATCH
PRINT ERROR_MESSAGE()
END CATCH



select * from ACC_AccDocRow
where DId=1102384
/*
Id	DId	RowNo	CodeId	CostCenterId	ProjectId	T1Id	T2Id	T2_FId	T2_AZId	T3Id	Detail	Document	Date	MonyId	MonyRatio	Bed	Bes	NBed	NBes	ChekNo	CheckDate	Quantity	MeasureId	ExternalData	OrgId	CheckId	T2Flg	ISPrePay	ISTempPey	CheckIsOK	ExportRowId	ImportRowId	EI_RowId	ChConflictCode	OrgDocNo	OrgRowNo	HasNValue	ISBed	RValue	RNValue	FullVALUE	RADA_FLG	UnitId	IsDirectImp_ExportRow
64709740	1102384	1	378	NULL	NULL	74809	21827	NULL	NULL	NULL	À»  »—ê‘  «“ „’—›    ò«·«Ì 190010200579 „—›Ì‰ «„ÅÊ· 10„	NULL	NULL	1	1	550800	0	0	0		NULL	120	NULL	824170	NULL	NULL	0	0	0	0	NULL	824170	NULL	0	0	0	0	1	550800	0	550800	0	NULL	NULL
64709741	1102384	2	1301	301	NULL	NULL	21827	NULL	NULL	NULL	À»  »—ê‘  «“ „’—›    ò«·«Ì 190010200579 „—›Ì‰ «„ÅÊ· 10„	NULL	NULL	1	1	0	550800	0	0		NULL	120	NULL	824170	NULL	NULL	0	0	0	0	NULL	824170	NULL	0	0	0	0	0	-550800	0	550800	0	1608	NULL
*/


select *
from STK_ReturnsEIList e
where e.IRId in (select Id from STK_GoodsImportRow 
					where GoodsImportId=197681)
/*
Id	EIId	Quantity	IRId	DRId
15243	2472379	120	824170	NULL
*/


declare @did int
set @did=1201982

/*
کد مرکز	نام مرکز	وضعیت مرکز	سال مالی	شناسه سند	شماره ردیف سند	نوع سند	وضعیت سند	id	کد حساب	نام حساب	تفصیل یک نیاز دارد	شناسه تفصیل یک	تفصیل دو نیاز دارد	شناسه تفصیل دو	تفصیل سه نیاز دارد	شناسه تفصیل سه	پروژه نیاز دارد	شناسه پروژه	مرکز هزینه	شناسه مرکز هزینه	واحد سازمانی
211	دانشگاه علوم پزشکي و خدمات بهداشتي درماني اهواز	مستقل	93	1201982	3	عادي	در انتظار رسيدگی	56702833	180109	پيش پرداخت خريد اقلام سرمايه‌اي	بله	72394	بله	18338	خیر	NULL	بله	NULL	خیر	NULL	NULL
*/

------------------------------------------------------------------------------------
Select 
	   t3.Code N'کد مرکز',
       t3.Name N'نام مرکز',
       case t3.Independent when 1 then N'مستقل' else N'غیرمستقل' end N'وضعیت مرکز' ,
       d.Year as N'سال مالی',
       cast(R.DId as nvarchar(max) ) AS N'شناسه سند',
       r.ROWNO AS N'شماره ردیف سند',
       CASE d.DocType 
			WHEN 0 then N'افتتاحيه حساب‌ها'
			WHEN   1 then N'اختتاميه'
			WHEN   2 then N'سود و زيان'
			WHEN  3 then N'عادي'
			WHEN  4 then N'اصلاحي'
			WHEN   5 then N'سيستم اموال'
			WHEN  6 then N'سيستم كالا'
			WHEN 7 then N'سيستم بودجه و اعتبارات'
			WHEN  8 then N'سيستم دريافت پرداخت'
			WHEN    9 then N'سيستم حقوق و دستمزد'
			WHEN  10 then N'ايجاد سوابق اموال'
			WHEN   11 then N'ايجاد سوابق كالا'
			WHEN   12 then N'ارسالي از واحد'
			WHEN   13 then N'سيستم تجميع اسناد'
			end  AS N'نوع سند',
		CASE d.state
	        WHEN 10 then N'آماده تایيد مقام مجاز جهت ثبت'
			WHEN 1 then N'در انتظار رسيدگی'
			WHEN 11 then N'آماده شناسایی کد اعتبار'
			WHEN 6 then N'آماده تایيد وصول مستندات'
			WHEN 9 then N'آماده تایيد مقام مجاز جهت برداشت وجه'
			WHEN 7 then N'آماده ارسال'
			WHEN 8 then N'نهایی'
			WHEN 4 then N'آماده ثبت عمليات دریافت - پرداخت'
			WHEN 2 then N'واخواهی شده یا همان برگشت از رسیدگی'
			WHEN 3 then N'آماده تامین اعتبار'
			WHEN 5 THEN N'آماده رسیدگی نهایی'
			WHEN  null then N'بدون سند'
		    ELSE ''
            END AS N'وضعیت سند',
         cast(R.Id as nvarchar(max)) as id,
         CASE WHEN c.code IS NULL THEN N'ندارد' ELSE c.code END AS N'کد حساب',
         c.name N'نام حساب',
         case when C2.HT1=0 THEN N'خیر' ELSE N'بله' end AS N'تفصیل یک نیاز دارد',
         r.T1Id N'شناسه تفصیل یک',
         case when C2.HT2=0 THEN N'خیر' ELSE N'بله' end AS N'تفصیل دو نیاز دارد',
         r.T2Id as N'شناسه تفصیل دو' ,
         case when C2.HT3=0 THEN N'خیر' ELSE N'بله' end AS N'تفصیل سه نیاز دارد',
         r.T3Id as N'شناسه تفصیل سه' ,
         case when C2.Hproj=0 THEN N'خیر' ELSE N'بله' end AS N'پروژه نیاز دارد', 
         ProjectId AS N'شناسه پروژه' ,
         case when C2.HCC=0 THEN N'خیر' ELSE N'بله' 
         end as N'مرکز هزینه',
         CostCenterId AS N'شناسه مرکز هزینه',
         UnitId as N'واحد سازمانی'
FROM dbo.ACC_AccDocRow AS R
Left Outer Join dbo.M_ACC_Codes2 AS C2 ON R.CodeId =  C2.Mid 					
left outer Join dbo.M_ACC_Codes As C ON c2.Mid=c.Id
inner join acc_Accdoc d on r.did=d.id --and d.year=90 and state not IN (8)
inner join m_org_T3 t3 on t3.Id=d.T3Id-- and d.T3Id=d.T3IdOrg
Where 
	

	(
			C2.Mid IS NULL 
		OR 
			(C2.HT1 = 1 AND R.T1Id IS NULL)
		OR
		
			(C2.HCC = 1 AND R.CostCenterId IS NULL and r.UnitId is null)
		OR
			(C2.HT3 = 1 AND R.T3Id IS NULL)
		OR
			(C2.HProj = 1 AND R.ProjectId IS NULL)
        OR
			(C2.Ht2 = 1 AND R.t2Id IS NULL) 	
		 )
		and d.id=@did
		
			order by 1
			
-----------------------------------------------------------------------------------------------------
 BEGIN TRY
 CREATE  TABLE #DIds (Id int , T3Id int , [Year] tinyint)

Insert Into #DIds (Id,T3Id,[Year])
SELECT Id,T3Id,[Year] FROM ACC_AccDoc D
WHERE d.id=@did 
order by D.T3Id,D.Year,D.UserDate,D.Id

Declare @STR NVARCHAR(MAX),@STRPARSMS NVARCHAR(MAX) =N' @DocId int'
SET @STR =' declare @Commit bit set @Commit=1
BEGIN TRAN A
 BEGIN TRY
     declare @LastFinal bit, @LastFinalByUser Bit
	 select @LastFinalbyUser = FinalbyUser, @LastFinal= Final from ACC_YEARS as Y
	 inner join ACC_AccDoc as D on Y.Year=D.Year and Y.T3Id=D.T3Id where D.Id = @DocId 
	 
	 IF @LastFinalByUser = 1 or @LastFinal=1
	 Update Y set Final = 0, FinalByUser= 0
	 from ACC_YEARS as Y inner join ACC_AccDoc AS D on Y.Year = D.Year and Y.T3Id = D.T3Id where D.Id = @DocId 
	 
	 PRINT @DocId
	
	DECLARE @UserDate DateTime,@AuditorId int ,@T3ID int,@DetailOfDoc NVARCHAR(1000),@DetailText NVARCHAR(1000),@ControlCode NVARCHAR(10),@Year tinyint,@NewId bigint,@state TINYINT, @NewState TINYINT
	SELECT  @state = [State] from ACC_AccDoc where id = @docId
	
	--Update 	ACC_AccDoc SET State = 5,@T3ID = T3Id,@AuditorId = (select Min(Id) from Org_Personnel where T3Id = @T3Id),@DetailOfDoc = Detail
	--Output inserted.Id INTO #DIds (Id)
 --   WHERE Id = @DocId
	
	
	exec usp_ACC_Save_GetNewState @docid, @state, @NewState OUTPUT
				           Exec dbo.usp_ACC_Save_SetDocDateAndNo
							@Id = @DocId
						   ,@UserId = @AuditorId
						   ,@NewState = 6
						   ,@ISAUDCall  = 1



Update dbo.ACC_AccDoc Set Finishd = 1,DafUserId = @AuditorId,DafOKDate = GETDATE(),State = 8 , @Year = YEAR ,@UserDate = ISNULL(UserDate,Date) WHERE Id = @DocId					
				  
	If @LastFinal=1 or @LastFinalByUser=1
	Update Y set Final = @LastFinal,FinalByUser=@LastFinalByUser
	from ACC_YEARS as Y inner join ACC_AccDoc as D on Y.Year = D.Year and Y.T3Id = D.T3Id WHERE D.Id = @DocId



  IF (@Commit = 1)
    BEGIN
        PRINT ''DONE: ALL - COMMIT''
        COMMIT TRAN A
    END
    ELSE
    BEGIN
        PRINT ''DONE: ALL - ROLLBACK''
        ROLLBACK TRAN A
    END
END TRY
BEGIN CATCH
    Declare @Message VARCHAR(MAX)
    Set @Message = ERROR_MESSAGE()
    ROLLBACK TRAN A
    Exec usp_None_Load_RAISERROR @Message
END CATCH	
	'
SELECT * FROM ACC_AccDoc WHERE Id in (SELECT Id From #DIds)
DECLARE @STREXEC NVARCHAR(MAX) 
WHILE 1=1
BEGIN
	SET @STREXEC = N''
	SELECT TOP(50) @STREXEC = @STREXEC + N'
	execute sp_executesql @STR,@STRPARSMS,@DocId = ' + CAST(D.Id AS NVARCHAR) 
	FROM ACC_AccDoc D
	Inner JOIN M_ORG_T3 T3 ON T3.Id = D.T3Id
	Inner JOIN #DIds DI ON D.Id = DI.Id
	WHERE D.DocNo = 0
	order by D.T3Id,D.Year,D.UserDate,D.Id 
	;
	IF LEN(ISNULL(@STREXEC,'')) > 10
	BEGIN
		PRINT @STREXEC
		;
		execute sp_executesql @STREXEC,N'@STR NVARCHAR(MAX),@STRPARSMS NVARCHAR(MAX)',@STR,@STRPARSMS
	END
	ELSE
		BREAK

END


END TRY
BEGIN CATCH
    Declare @Message VARCHAR(MAX)
    Set @Message = ERROR_MESSAGE()
    Exec usp_None_Load_RAISERROR @Message
END CATCH

SELECT Id,',' FROm ACC_ACCDOC WHERE Id in (SELECT Id FROM #DIds)
SELECT DocNo,State,* FROm ACC_ACCDOC WHERE Id in (SELECT Id FROM #DIds)
;
DROP TABLE #DIds

/*
Id	T3Id	T3IdOrg	DocType	Detail	ExternalNote	ExternalId	Date	AuditorId	DocNo	DaybookNo	NDocNo	NDaybookNo	PrinterId	PrintDate	Finishd	SendForT3owner	DocIdAtOrg	RejectedByAouditor	RejectDetail	DafUserId	DafOKDate	State	Year	UserDate	QuanOfAttached	ControlCode	T2FlgDate	T2Flg	IsIndependent	ExportId	ImportId	ControlCodeInt	Candel
1201982	271043	271043	3	بابت اصلاح پروژه پيش پرداخت شرکت بازفت کار ايذه		-1	2015-03-15 13:13:56.007	7518	0	0	0	0	7518	2015-03-15 13:13:56.007	0	0	NULL	0		NULL	NULL	1	93	2015-03-15 00:00:00.000	0		2015-03-15 13:13:56.267	0	NULL	NULL	NULL	0	1
*/





/*
DocNo	State	Id	T3Id	T3IdOrg	DocType	Detail	ExternalNote	ExternalId	Date	AuditorId	DocNo	DaybookNo	NDocNo	NDaybookNo	PrinterId	PrintDate	Finishd	SendForT3owner	DocIdAtOrg	RejectedByAouditor	RejectDetail	DafUserId	DafOKDate	State	Year	UserDate	QuanOfAttached	ControlCode	T2FlgDate	T2Flg	IsIndependent	ExportId	ImportId	ControlCodeInt	Candel
18111	8	1201982	271043	271043	3	بابت اصلاح پروژه پيش پرداخت شرکت بازفت کار ايذه		-1	2015-03-17 00:00:00.000	NULL	18111	244	18111	244	7518	2015-03-15 13:13:56.007	1	0	NULL	0		NULL	2015-03-17 09:57:19.877	8	93	2015-03-15 00:00:00.000	0		2015-03-17 09:57:19.793	1	1	NULL	NULL	0	1
*/




BEGIN TRY 
CREATE  TABLE #DIds (Id int , T3Id int , [Year] tinyint)
INSERT	INTO #DIds (Id,T3Id,[Year])
SELECT	Id,T3Id,[Year] FROM ACC_AccDoc D
WHERE  
	state in (6,7) 
	and 
	ID in (3643,3644,3723,3724,3731,3733,3736,3737,3738,3740,
3741,3747,3748,3749,3750,3759,3765,3800,3804,3816,
3817,3819,3820,3821,3822,3824,3825,3829,3830,3859,
3878,3895,3899,3901,3902,3906,3907,3908,3910,3911,
3916,3941,3942,3943,3945,3946,3947,3948,3949,3950,
3963,3964,3965,3969,3970,3973,3974,3976,3980,3984,
3986,3987,3989,3990,4012,4013,4054,4057,4150,4151,
4152,4161,4163,4165,4170,4172,5689,5690,5691,5844,
6127,6131,6132,6133,6134,6135,6136,6138,6139,6144,
6147,6238,6284,6381,6384,6386,6387,6389,6390,6396,
6404,6410,6413,6685,6768,6784,6790,6897,6905,6908,
6910,6911,6912,6913,6914,6915,6917,6918,6919,6921,
6923,6924,6925,6926,6928,6929,6933,6935,7646,7656,
9467,9468,9632,9635,9636,9637,9639,9641,9642,9644,
9685,9690,9691,9694,9698,9702,9705,9707,9710,9725)---یا هر شرط دلخواه
		
ORDER BY D.T3Id,D.Year,D.UserDate,D.Id

Declare @STR NVARCHAR(MAX),@STRPARSMS NVARCHAR(MAX) =N' @DocId int'
SET @STR ='
BEGIN TRY
BEGIN TRAN A
	declare @Commit bit set @Commit=1
	PRINT @DocId
	DECLARE @AuditorId int,@T3ID bigint,@state tinyint,@yy tinyint
    DECLARE @f bit ,@fu bit
	select  	
	        @T3ID = T3Id,
		    @AuditorId = (select Min(Id) from Org_Personnel where T3Id = @T3Id)
		   ,@state=state
		   ,@yy=[year]
		  from ACC_AccDoc 
    WHERE Id = @DocId
    
    select  @f=Final,@fu=FinalByUser 
		  from ACC_Years
    WHERE T3Id=@T3id AND YEAR=@yy
    
   ------------------قفل سال مالی را بر می دارد 
    if (@f=1 or @fu=1)
    Begin
		update ACC_Years
		set Final=0,FinalByUser=0   
		WHERE T3Id=@T3id AND YEAR=@yy
    End
     
  ----state in 1 or 10---
    ----سند در انتظار رسیدگی یا پیش نویس باشد آن را در حالت آماده رسیدگی نهایی قرار می دهد  
    
    if @state  in (1,10)
		begin
			update Acc_Accdoc 
			set state=5
		    where id=@docid 
		end
    
    
    select @state=state
	from Acc_Accdoc where id=@DocId
  
  -------------state not in in 6,7,8---------------->0,2,4,5,9,11
    --سند را در وضعیت هایی غیر از وصول مستندات، آماده ارسال و نهایی بررسی می نماید
    if @state not in(6,7,8)
		Begin
			DECLARE @new TINYINT
			
			exec usp_ACC_Save_GetNewState @DocId = @DocID, 
							 @LastState=@state  , @NewState = @new OUT
		----این پروسیجر یک وضعیت جدید به سند می دهد که خروجی آن شامل وضعیت های 0 و 2 و 3 نمی شود					 
	--------------------------------output all except 0,2,3					 
    SELECT @new AS newstate
    
    --اگر خروجی تولید شده در اثر اجرای پروسیجر بالا 6 باشد یعنی سند در وضعیت آماده تهیه وصول مستندات باشد دستورات زیر اجرا می شود
    IF @new = 6
    Begin
    Exec dbo.usp_ACC_Save_SetDocDateAndNo
    --اگر سند قابل شناسایی نباشد یا سال مالی آن اشتباه باشد پیغام خطا می دهد و گر نه تاریخ سند را در سال مالی جاری ایجاد می نماید
		@Id = @DocId
	   ,@UserId = @AuditorId
	   ,@NewState = 6
	   ,@ISAUDCall  = 1
	END
	END
	select @state=state
	from Acc_Accdoc where id=@DocId
	
	----------------------------------------------در این حالت سند در وضعیت آماده تهیه صدور مستندات قرار گرفته است یعنی نواقصات نداشته است
	IF @state=6
	BEGIN
	  
	  EXEC dbo.usp_ACC_Save_FinishAndOKDoc 
	  --این پروسیجر مراحل نهایی کردن سند را اجرا می نماید
	  @DocId =@DocId,@UserId = @AuditorId,@QuanOfAttached=1
	
	END
	
    select @state=state
	from Acc_Accdoc where id=@DocId
	--اگر سند آماده ارسال به ستاد باشد وضعیت 7 می شود یعنی واحد غیر مستقل بوده است
	IF @state=7
	BEGIN
	     
		EXEC [dbo].[usp_ACC_Save_SendDocToT3Owner] 
	--	--این پروسیجر مراحل ارسال سند به ستاد را انجام می دهد
		@UserId =@AuditorId,@Id = @DocId,@CanMerge = 0,@SelectANDReturn = 0
	END
	
	----قفل سال مالی را بر می دارد
	if ( @f=1 or @fu=1)
    Begin
    update ACC_Years
     set Final=@f,FinalByUser=@fu   
     WHERE T3Id=@T3id AND YEAR=@yy
    End
	
	
	---مراحل نهایی شدن فرآیند انجام می شود
	
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
			INNER JOIN M_ORG_T3 T3 ON T3.Id = D.T3Id
			INNER JOIN #DIds DI ON D.Id = DI.Id
		WHERE  
		
		state in (6,7) 
			 
		AND
	d.ID in (3643,3644,3723,3724,3731,3733,3736,3737,3738,3740,
3741,3747,3748,3749,3750,3759,3765,3800,3804,3816,
3817,3819,3820,3821,3822,3824,3825,3829,3830,3859,
3878,3895,3899,3901,3902,3906,3907,3908,3910,3911,
3916,3941,3942,3943,3945,3946,3947,3948,3949,3950,
3963,3964,3965,3969,3970,3973,3974,3976,3980,3984,
3986,3987,3989,3990,4012,4013,4054,4057,4150,4151,
4152,4161,4163,4165,4170,4172,5689,5690,5691,5844,
6127,6131,6132,6133,6134,6135,6136,6138,6139,6144,
6147,6238,6284,6381,6384,6386,6387,6389,6390,6396,
6404,6410,6413,6685,6768,6784,6790,6897,6905,6908,
6910,6911,6912,6913,6914,6915,6917,6918,6919,6921,
6923,6924,6925,6926,6928,6929,6933,6935,7646,7656,
9467,9468,9632,9635,9636,9637,9639,9641,9642,9644,
9685,9690,9691,9694,9698,9702,9705,9707,9710,9725)--یا هر شرط دلخواه
		
		ORDER BY D.T3Id,D.Year,D.UserDate,D.Id
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


select State,*
from ACC_AccDoc d 
 where d.Id in (11896,159927,159938,3944,159939,11882)


declare @id int=0
declare @count int=0
--یک کرسر برای خواندن شناسه ها ایجاد می گردد
declare c cursor for
	select id from ACC_AccDoc
	where id in (11896,159927,159938,3944,159939,11882)--شناسه اسناد درحواستی در این بخش درج می گردد
--order by id
--کرسر باز می شود
open c
--کرسر اولین شناسه را می خواند
FETCH NEXT FROM c
INTO @id
--تا وقتی که کل شناسه ها در شرط بالا بررسی شود خواندن شناسه ها به ترتیب انجام می شود
while @@FETCH_STATUS=0
	Begin
		exec USP_ACC_SAVE_CtrlDocNature @DId = @id--خلاف ماهیت چک می شود
		if @@ERROR>0--اگر خلاف ماهیت داشته باشد شماره سند را نمایش می دهد و تعداد اسناد دارای خلاف ماهیت را شمارش می نماید
			Begin
		
				print 'سند شماره '+cast(@id as nvarchar(10))+' دارای خلاف ماهیت است'
		
				set @count=@count+1
	
			End
			--اگر خلاف ماهیت نداشته باشد اسناد را نهایی می نماید
			else 
				Begin
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


exec sp_executesql @STR,@STRPARSMS ,@DocId=@id

				End
	
		FETCH NEXT FROM c
		INTO @id
--شرط ادامه حلقه
	End
print 'تعداد'+cast(@count as nvarchar(10))+' سند دارای خلاف ماهیت است'


close c
deallocate c
select @count

	select State,*
from ACC_AccDoc d 
 where d.Id in (11896,159927,159938,3944,159939,11882)
	

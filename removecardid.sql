
Declare @STR NVARCHAR(MAX),@STRPARSMS NVARCHAR(MAX) =N' @cardid int'
set @STR='
declare @Commit bit set @Commit=0
select typeindex into #card 
from AST_History
where CardId=@cardid

declare @strMessage1 nvarchar(100)=''''
declare @strMessage2 nvarchar(100)=''''
DECLARE @AMORTIZATION BIGINT=0


if (select count(cardid) from AST_History where CardId=@cardid)=0
Begin
	set @strMessage1=''کارت اموال با شناسه''+CONVERT(nvarchar(100),@cardid)+'' وجود ندارد''
	RaisError(@strMessage1,16,1)
End
else
	   SET @AMORTIZATION=(select SUM(Amortization) from AST_StoredHistory where CardId=@cardid)
	   
if (select COUNT(typeindex) from #card where typeindex<>0 and typeindex<>1 and typeindex<>8)!=0
     OR (@AMORTIZATION>0)
     
	Begin 
		set @strMessage2=''امکان پاک کردن کارت اموال با شناسه ''+CONVERT(nvarchar(100),@cardid)+'' وجود ندارد''
		RaisError(@strMessage2,16,1)
	end
else
Begin
	begin try
		Begin tran A
		
		 if exists (select cardid from AST_HolderExpiredHistory where CardId=@cardid)
			Begin
				delete from AST_HolderExpiredHistory
				where CardId=@cardid
			End
			
			delete from ast_storedhistory
			where CardId=@cardid

			delete from AST_History
			where CardId=@cardid

			delete from AST_Card
			where id=@cardid

 IF (@Commit = 1)
    BEGIN
        PRINT ''کارت اموال با شناسه''+CONVERT(nvarchar(100),@cardid)+''پاک شد''
        COMMIT TRAN A
    END
    ELSE
    BEGIN
        PRINT ''ID: ''+CONVERT(nvarchar(100),@cardid)+'' Removed in Rollback''
                ROLLBACK TRAN A
    END
END TRY
BEGIN CATCH
    Declare @Message VARCHAR(MAX)
    Set @Message = ERROR_MESSAGE()
    ROLLBACK TRAN A
    Exec usp_None_Load_RAISERROR @Message
END CATCH
End
drop table #card
'
exec sp_executesql @STR,@STRPARSMS ,@cardid=404




use booshehr
declare @id int=0
declare @count int=0
declare @tid table(id bigint)
declare c cursor for
select id from ACC_AccDoc
where id in (159927,159938,3639,159939,3637)
--order by id

open c

FETCH NEXT FROM c
INTO @id

while @@FETCH_STATUS=0
	Begin
		exec USP_ACC_SAVE_CtrlDocNature @DId = @id
		if @@ERROR>0
			Begin
				insert into @tid(id)
				output inserted.id into @tid(id)
				select @ID from ACC_AccDoc
				
			print @id
				set @count=@count+1
			--	select * from @did
				select @count
				print @count
			End
		
		FETCH NEXT FROM c
		INTO @id
select * from @tid	
	select @count	
	End

close c
deallocate c
select @count
	
	
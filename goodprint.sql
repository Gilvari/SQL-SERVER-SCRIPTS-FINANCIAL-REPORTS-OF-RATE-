declare @str nvarchar(max)='a,b,c,d,e,f,g,h,i,j,1,2,3,4,5,6,7,8,9,d,e,f,g,h,i,j,1,2,3,c,d,e,f,g,h,i,j,1,2,3,4,5,6,7,8,9,d,e,f,g,h,i'
declare @position int =1
declare @count int=0;
declare @x int=1;
declare @s nchar(1)
while @position<=LEN(@str)
begin
set @s=SUBSTRING(@str,@position,1)
if @s=','
	begin
	set @count=@count+1;
	if @count=@x*20
		begin
		set @x+=1;
		print left(@str,@position)
		set @str=substring(@str,@position+1,len(@str)-@position+1)
		set @position=1;
		end
		
	end
set @position=@position+1;
end
print @str
--select @count
/*
	Author:		MR.Tarkhan AND B.Fallah
	Date:		01-06-2016
	
	First Review:
		Reviewer:
		Date:
	Second Review:
		Reviewer:
		Date:
			 
*/
DECLARE @position int =1
DECLARE @count int=0;
DECLARE @x int=1;
DECLARE @s nchar(1)
DECLARE @str NVARCHAR(MAX) = 
-- Paste Between Qutations
'
125,4545454,878787,8787


';

SET @str = REPLACE (REPLACE (REPLACE (@str,CHAR(9), '') ,CHAR(10), '') ,',', CHAR(13));


WHILE @position<=LEN(@str)
BEGIN
	SET @s=SUBSTRING(@str,@position,1)
	
	--IF @s=','
	--	BEGIN
	--		SET @count=@count+1;
			
	--		IF @count=@x*10
	--			BEGIN
	--				SET @x+=1;
	--				print left(@str,@position)
	--				SET @str=substring(@str,@position+1,len(@str)-@position+1)
	--				SET @position=1;
	--			END
			
		--END
		
	SET @position=@position+1;
	
END 
print @str
--select @count


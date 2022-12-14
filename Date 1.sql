
--تبدیل تاریخ میلادی به شمسی


GO
/****** Object:  UserDefinedFunction [dbo].[com_udfGetChristianDate]    Script Date: 10/07/2015 08:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create FUNCTION [dbo].[com_udfGetChristianDate](@SolarDate varchar(10)) RETURNS smalldatetime  AS BEGIN
       IF LEN(@SolarDate) = 8
              SET @SolarDate = '13' + @SolarDate
       DECLARE @SolarYear int, @SolarMonth int, @SolarDay int
       DECLARE @I int, @TempYear int, @Leap int, @DayOfYear int
       DECLARE @Result smalldatetime
       SET @SolarYear  = CAST(LEFT(@SolarDate, 4) AS int)
       SET @SolarMonth = CAST(RIGHT(LEFT(@SolarDate, 7), 2) AS int)
       SET @SolarDay   = CAST(RIGHT(@SolarDate, 2) AS int)
       IF @SolarMonth >= 7
              SET @DayOfYear = 31 * 6 + (@SolarMonth-7) * 30 + @SolarDay
       ELSE
              SET @DayOfYear = (@SolarMonth-1) * 31 + @SolarDay
       IF @SolarYear = 1278
              SET @Result = @DayOfYear-(31*6 + 3*30+11)
       ELSE BEGIN
              SET @Result = 365 - (31*6 + 3*30+11) + 1
              SET @I = 1279
              WHILE @I < @SolarYear BEGIN
                     SET @TempYear = @I + 11
                     SET @TempYear = @TempYear - ( @TempYear / 33) * 33
                     IF  (@TempYear <> 32) and ( (@TempYear / 4) * 4 = @TempYear )
                           SET @Leap = 1
                     ELSE
                           SET @Leap = 0
                     IF @Leap = 1
                           SET @Result = @Result + 366
                     ELSE
                           SET @Result = @Result + 365
                     SET @I = @I + 1
              END
              SET @Result = @Result + @DayOfYear - 1 
       END
       RETURN @Result
END

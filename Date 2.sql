

--تبدیل تاریخ شمسی به میلادی


GO
/****** Object:  UserDefinedFunction [dbo].[com_udfGetSolarDate]    Script Date: 10/07/2015 08:51:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create FUNCTION [dbo].[com_udfGetSolarDate](@EDate smalldatetime) RETURNS varchar(10)  AS BEGIN
       DECLARE @FDate varchar(10) 
       DECLARE @EYear int, @EMon smallint, @EDay smallint, @ELeap bit, @EMonArray Char(12), @EDayOfYear int 
       DECLARE @FYear int, @FMon smallint, @FDay smallint, @FLeap bit, @FMonArray Char(12) 
       SELECT @FMonArray = Char(31) + Char(31) + Char(31) + Char(31) + Char(31) + Char(31) + Char(30) + Char(30) + Char(30) + Char(30) + Char(30) + Char(29) 
       SELECT @EMonArray = Char(31) + Char(28) + Char(31) + Char(30) + Char(31) + Char(30) + Char(31) + Char(31) + Char(30) + Char(31) + Char(30) + Char(31) 
       SELECT @EYear = Year(@EDate) 
       SELECT @EMon = Month(@EDate) 
       SELECT @EDay = Day(@EDate) 
       IF (@EYear %4) = 0 SELECT @ELeap = 1 ELSE SELECT @ELeap = 0 
       --------------------- Calc Day Of Year 
       DECLARE @Temp int, @Cnt int 
       SELECT @Cnt = @EMon-1 
       SELECT @Temp = 0 
       WHILE @Cnt<>0 BEGIN 
              IF (@Cnt = 2)AND(@ELeap = 1)
                     SELECT @Temp = @Temp + 29 
              ELSE
                     SELECT @Temp = @Temp + Ascii(Substring(@EMonArray, @Cnt, 1)) 
              SELECT @Cnt = @Cnt-1 
       END 
       SELECT @EDayOfYear = @Temp + @EDay 
       ---------------------- Convert to Farsi 
       SELECT @Temp = @EDayOfYear-79 
       IF @Temp>0
              SELECT @FYear = @EYear-621 
       ELSE BEGIN 
              SELECT @FYear = @EYear-622 
              IF ((@FYear %4) = 3)
                     SELECT @Temp = @Temp + 366
              ELSE
                     SELECT @Temp = @Temp + 365 
       END
       IF (@FYear %4) = 3
              SELECT @FLeap = 1
       ELSE
              SELECT @FLeap = 0
       SELECT @Cnt = 1
       WHILE (@Temp<>0) AND (@Temp>Ascii(Substring(@FMonArray, @Cnt, 1)))   BEGIN 
              IF @Cnt = 12 
                     IF (@FLeap = 1)
                           SELECT @Temp = @Temp-30
                     ELSE
                           SELECT @Temp = @Temp-29 
              ELSE
                     SELECT @Temp = @Temp-Ascii(Substring(@FMonArray, @Cnt, 1)) 
              SELECT @Cnt = @Cnt + 1 
       END 
       IF @Temp<>0 BEGIN 
              SELECT @FMon = @Cnt 
              SELECT @FDay = @Temp 
       END ELSE BEGIN 
              SELECT @FMon = 12 
              SELECT @FDay = 30 
       END
       ------- Some years has a one_day disposition and has to be corrected manually!!!
       IF @FYear IN (1301, 1302, 1303, 1304, 1305, 1306, 1307, 1310, 1311, 1314, 1315, 1318, 1319, 1322, 1323, 1326, 1327, 1330, 1331, 1334, 1335, 1338, 1339, 1343, 1347, 1351, 1355, 1359, 1363, 1367, 1371)
       BEGIN
              SET @FDay = @FDay - 1
              IF (@FDay = 0)
                     BEGIN 
                           IF @FMon > 1
                                  BEGIN
                                         SET @FMon = @FMon - 1
                                         SET @FDay = Ascii(Substring(@FMonArray,@FMon , 1)) 
                                  END    
                           ELSE
                                  BEGIN 
                                         SET @FMon = 12
                                         SET @FYear = @FYear - 1
                                         IF (@FYear >= 1375 AND (@FYear % 4) = 3) OR (@FYear < 1375 AND (@FYear % 4) = 2) 
                                                SET @FDay = 30
                                         ELSE
                                                SET @FDay = 29
                                  END
                     END                        
       END
       ------------------ ALTER Output 
       DECLARE @YStr Char(4), @MStr char(2), @DStr Char(2) 
       SELECT @YStr = Convert(Char, @FYear) 
       IF @FMon<10 
              SELECT @MStr = '0' + Convert(Char,@FMon)
       ELSE
              SELECT @MStr = Convert(Char, @FMon) 
       IF @FDay<10 
              SELECT @DStr = '0' + Convert(Char,@FDay)
       ELSE
              SELECT @DStr = Convert(Char, @FDay) 
       SELECT @FDate = @YStr + '/' + @MStr + '/' + @DStr 
       ------------------
       RETURN @FDate
END

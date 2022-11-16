
/*.....ابتدای دوره - تکمیل افتتاحیه.....*/

CREATE TABLE #DATAT (T3Id INT, DocId BIGINT)

BEGIN TRY
BEGIN TRAN A

DECLARE @NewDId BIGINT,
		@NewDocYear TINYINT = 93,
		@T3Code BIGINT = 253,
		@AllUnits BIT = 0,
		@CloseWithCode INT = 329909 --با چه کدحسابی بسته شود

DECLARE @AccCodesForClose TABLE (CodeId INT)
DECLARE @Detail NVARCHAR (150)
SELECT @Detail = dbo.UF_YK_Replacer(N'بابت اصلاح مانده حساب های ابتدا دوره کد حساب 329909 مرکز 253 در سال 94 ')

-- ایجاد یک سند از نوع تکمیل افتتاحیه و قسمتی از اطلاعاتش را پر کردیم
INSERT INTO [dbo].[ACC_AccDoc]
           ([T3Id]
           ,[T3IdOrg]
           ,[DocType]
           ,[Detail]
           ,[ExternalNote]
           ,[ExternalId]
           ,[Date]
           ,[AuditorId]
           ,[DocNo]
           ,[DaybookNo]
           ,[NDocNo]
           ,[NDaybookNo]
           ,[PrinterId]
           ,[PrintDate]
           ,[Finishd]
           ,[SendForT3owner]
           ,[DocIdAtOrg]
           ,[RejectedByAouditor]
           ,[RejectDetail]
           ,[DafUserId]
           ,[DafOKDate]
           ,[State]
           ,[Year]
           ,[UserDate]
           ,[QuanOfAttached]
           ,[ControlCode]
           ,[T2FlgDate]
           ,[T2Flg]
           ,[IsIndependent]
           ,[ExportId]
           ,[ImportId]
           ,[ControlCodeInt]
           ,[Candel])
	OUTPUT inserted.T3Id, inserted.Id INTO #DATAT (T3Id, DocId)
    SELECT DISTINCT
            T3.Id T3Id
           ,T3.Id [T3IdOrg]   -- T3Id = T3Org یعنی سند مال خود ستاد است
           ,0 AS DocType    -- نوع تکمیل افتتاحیه
           ,@Detail AS Detail
           ,N'' AS ExternalNote
           ,NULL AS ExternalId
           ,'2015/3/24 00:00:00' AS Date
           ,(SELECT MIN(p.Id) FROM ORG_PERSONNEL p WHERE p.T3Id = T3.Id) AuditorId
           ,0
           ,0
           ,0
           ,0
           ,(SELECT MIN(p.Id) FROM ORG_PERSONNEL p WHERE p.T3Id = T3.Id) PrinterId
           ,'2015/3/24 00:00:00' AS PrintDate
           ,0
           ,0
           ,NULL
           ,0
           ,''
           ,(SELECT MIN(p.Id) FROM ORG_PERSONNEL p WHERE p.T3Id = T3.Id) DafUserId
           ,'2015/3/24 00:00:00' AS DafOKDate
           ,5 STATE
           ,@NewDocYear AS [Year]
           ,'2015/3/24 00:00:00' AS UserDate
           ,0 AS QuanOfAttached
           ,0 AS ControlCode
           ,'2015/3/24 00:00:00' AS T2FlgDate
           ,0
           ,0 IsIndependent
           ,NULL ExportId
           ,NULL ImportId
           ,0 ControlCodeInt
           ,1 Candel
          FROM M_ORG_T3 T3 
          WHERE
          (
			  (@AllUnits = 1 AND T3.Code LIKE (CAST(@T3Code AS VARCHAR) + '%'))
			   OR
			  (@AllUnits = 0 AND T3.Code = @T3Code) -- فقط ستاد
		  )
          AND (SELECT MIN(p.Id) FROM ORG_PERSONNEL p WHERE p.T3Id = T3.Id) IS NOT NULL


;WITH DATA AS
(
SELECT
           d.T3Id AS DT3Id
           ,c.Code AS CCode
           ,dr.CodeId
           ,dr.CostCenterId
           ,dr.ProjectId
           ,dr.T1Id
           ,dr.T2Id
           ,dr.T3Id
           ,dr.UnitId
           ,SUM(Bed - Bes) AS V  
           ,SUM(NBed - NBes) AS NV
           ,dr.ISPrePay
           ,dr.ISTempPey
         FROM dbo.ACC_AccDocRow dr
         INNER JOIN ACC_AccDoc d ON dr.DId = d.Id
         INNER JOIN M_ACC_Codes c ON dr.CodeId = c.Id
         WHERE d.Year = 94
			   AND d.doctype=0 --ابتدای دوره
			   and d.DocNo>0
			   AND d.T3Id IN (SELECT Id FROM dbo.M_ORG_T3 WHERE Code = '253') -- Setad
			   --AND dr.T3Id IN (SELECT Id FROM M_ORG_T3 WHERE CAST(Code AS BIGINT) like '253%')
			   and dr.T3Id is not null
               and c.Code in ('329909')
			   

         GROUP BY
			  d.T3Id
			 ,c.Code
			 ,dr.CodeId
			 ,dr.CostCenterId
			 ,dr.ProjectId
			 ,dr.T1Id
			 ,dr.T2Id
			 ,dr.T3Id
			 ,dr.ISPrePay
			 ,dr.ISTempPey
			 ,dr.UnitId
		HAVING SUM(Bed - Bes) <> 0 OR SUM(NBed - NBes) <> 0 -- اون سندهایی که تراز نیستند),
DATAALL AS
(
      SELECT
            DId
           ,DT3Id
           ,CodeId
           ,CostCenterId
           ,ProjectId
           ,T1Id
           ,T2Id
           ,T3Id
           ,CASE WHEN dr.R = 1 AND V > 0 THEN V ELSE 0 END AS BED
           ,CASE WHEN dr.R = 2 AND V < 0 THEN ABS(V) ELSE 0 END AS BES
           ,CASE WHEN dr.R = 3 AND NV > 0 THEN NV ELSE 0 END AS NBED
           ,CASE WHEN dr.R = 4 AND NV < 0 THEN ABS(NV) ELSE 0 END AS NBES
           ,ISPrePay
           ,ISTempPey
           ,dr.R AS ORD
           ,CCode
           ,[UnitId]
         FROM DATA d
         CROSS JOIN (SELECT 1 R UNION ALL SELECT 2 R UNION ALL SELECT 3 R UNION ALL SELECT 4 R) dr

),
ALLOK00 AS
(
	SELECT
		 DId
		,DT3Id
		,CodeId
		,CostCenterId
		,ProjectId
		,T1Id
		,T2Id
		,T3Id
		,BES AS BED  -- معکوس
		,BED AS BES
		,NBES AS NBED
		,NBED AS NBES
		,ISPrePay
		,ISTempPey
		,ORD
		,CCode
		,0 AS ORD2
		,DATAALL.UnitId
     FROM DATAALL

    UNION ALL
	SELECT
		 DId
		,DT3Id
		,(SELECT Id FROM M_ACC_Codes WHERE Code = @CloseWithCode) AS CodeId
		,NULL AS CostCenterId
		,NULL AS ProjectId
		,NULL AS T1Id
		,T2Id
		,T3Id
		,BED AS BED
		,BES AS BES
		,NBED AS NBED
		,NBES AS NBES
		,0 AS ISPrePay
		,0 AS ISTempPey
		,ORD
		,CCode
		,1 AS ORD2
		,NULL AS UnitId
     FROM DATAALL
)
,
ALLOK AS
(SELECT * FROM ALLOK00 WHERE Bed > 0 OR Bes > 0 OR NBed > 0 OR NBes > 0)

INSERT INTO [dbo].[ACC_AccDocRow]
           ([DId]
           ,[RowNo]
           ,[CodeId]
           ,[CostCenterId]
           ,[ProjectId]
           ,[T1Id]
           ,[T2Id]
           ,[T2_FId]
           ,[T2_AZId]
           ,[T3Id]
           ,[Detail]
           ,[Document]
           ,[Date]
           ,[MonyId]
           ,[MonyRatio]
           ,[Bed]
           ,[Bes]
           ,[NBed]
           ,[NBes]
           ,[ChekNo]
           ,[CheckDate]
           ,[Quantity]
           ,[MeasureId]
           ,[ExternalData]
           ,[OrgId]
           ,[CheckId]
           ,[T2Flg]
           ,[ISPrePay]
           ,[ISTempPey]
           --,[CheckIsOK]
           --,[ExportRowId]
           --,[ImportRowId]
           --,[EI_RowId]
           --,[ChConflictCode]
           --,[OrgDocNo]
           --,[OrgRowNo]
           ,[UnitId]
           )
SELECT
            DId AS DId
           ,ROW_NUMBER () OVER (PARTITION BY DT3Id, DId ORDER BY DT3Id, DId, ORD, CCode, ORD2) AS RowNo
           ,dr.CodeId
           ,dr.CostCenterId
           ,dr.ProjectId
           ,dr.T1Id
           ,dr.T2Id
           ,NULL T2_FId
           ,NULL T2_AZId
           ,dr.T3Id
           ,N'بابت اصلاح مانده حساب' Detail
           ,N'' Document
           ,NULL Date
           ,1 MonyId
           ,1 MonyRatio
           ,Bed 
           ,Bes
           ,NBed
           ,NBes
           ,N'' ChekNo
           ,NULL CheckDate
           ,0 Quantity
           ,NULL MeasureId
           ,NULL ExternalData
           ,NULL OrgId
           ,NULL CheckId
           ,0 T2Flg
           ,dr.ISPrePay
           ,dr.ISTempPey
           --,0 CheckIsOK
           --,NULL ExportRowId
           --,NULL ImportRowId
           --,NULL EI_RowId
           --,0 ChConflictCode
           --,0 OrgDocNo
           --,0 OrgRowNo
           ,[UnitId]
         FROM ALLOK dr


SELECT * FROM #DATAT dt
INNER JOIN ACC_AccDoc d ON dt.DocId = d.Id
LEFT OUTER JOIN ACC_AccDocRow dr ON dr.DId = d.Id

--سندی که ردیف سند ندارد
SELECT * FROM #DATAT dt
INNER JOIN ACC_AccDoc d ON dt.DocId = d.Id
LEFT OUTER JOIN ACC_AccDocRow dr ON dr.DId = d.Id
WHERE dr.RowNo IS NULL

--پاک کردن سندهایی که ردیف سند ندارند
DELETE FROM d
FROM #DATAT dt
INNER JOIN ACC_AccDoc d ON dt.DocId = d.Id
LEFT OUTER JOIN ACC_AccDocRow dr ON dr.DId = d.Id
WHERE dr.RowNo IS NULL

-- شماره سندهای افتتاحیه ای که برای واحد یا واحدهای مورد نظر موجود است
SELECT  DISTINCT dr.DId
FROM ACC_AccDoc d
INNER JOIN ACC_AccDocRow dr ON d.Id = dr.DId
WHERE (  d.Year = 94
			   AND d.doctype=0 --ابتدای دوره
			   and d.DocNo>0
			   AND d.T3Id IN (SELECT Id FROM dbo.M_ORG_T3 WHERE Code = '253') -- Setad
			   --AND dr.T3Id IN (SELECT Id FROM M_ORG_T3 WHERE CAST(Code AS BIGINT) like '253%')
			   and dr.T3Id is not null
               and c.Code in ('329909')
	  )


SELECT * FROM #DATAT d

SELECT * FROM ACC_AccDoc d
INNER JOIN ACC_AccDocRow dr ON d.Id = dr.DId
WHERE d.Id = (SELECT DocId FROM #DATAT)


ROLLBACK TRAN 
--COMMIT TRAN A
END TRY
BEGIN CATCH
SET NOCOUNT OFF
PRINT ERROR_MESSAGE()
ROLLBACK TRAN A
END CATCH

DROP TABLE #DATAT

/*

*/

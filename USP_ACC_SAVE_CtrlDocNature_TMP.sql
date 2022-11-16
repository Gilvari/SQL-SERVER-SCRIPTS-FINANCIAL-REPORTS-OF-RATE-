USE [booshehr]
GO
/****** Object:  StoredProcedure [dbo].[USP_ACC_SAVE_CtrlDocNature]    Script Date: 09/25/2016 13:02:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[USP_ACC_SAVE_CtrlDocNature_TMP]
	 @DId bigint
	,@WithT2 Bit = 1
	,@T3Id int = NULL
	,@Year tinyint
	 = NULL
	,@MaxOnDoc int = 100
	,@MaxOnAll int = 1000
	AS
	BEGIN



		IF @T3Id IS NULL OR @Year IS NULL
		SELECT @T3Id = T3Id , @Year = Year FROM ACC_AccDoc Where Id = @DId
		IF not EXISTS (SELECT * From dbo.ACC_YEARS WHERE T3Id=@T3Id and Year=@Year and CtrlDocAct=1) RETURN;
		DECLARE @ERRs int = 0,@Message NVARCHAR(MAX) = N''
		
	IF @Year < 95
	BEGIN	
		IF @WithT2 = 1
		begin 
			Select @Message = @Message + CAST(C.Code AS NVARCHAR) 
				+ N' - ' + C.Name + N' خلاف ماهيت تجميعي با تفصيل دو ' + CAST(DrCurr.T2Id as NVARCHAR) + N': ' 
				+ CAST(ABS(CAST((ISNULL(DrOld.VAL,0) + DrCurr.VAL)  AS Bigint)) AS NVARCHAR)
				+SPACE(2)+ CAST(CHAR(13) as NVARCHAR) 
			,@ERRs = @ERRs + 1
			FROM
			(
				SELECT 
					 SUM (Bed+NBed-Bes-NBes) VAL
					,[CodeId]
					--,ISNULL([CostCenterId],0) [CCId]
					,ISNULL([ProjectId],0) [PRJId]
					,ISNULL([T1Id],0) [T1Id]
					,ISNULL([T2Id],0) [T2Id]
					,ISNULL([T3Id],0) [T3Id]
					,ISNULL(MonyId,1) MoneyId
				 FROM [dbo].[ACC_AccDocRow] 
				 Where DId = @DId
				 Group by 	
					 [CodeId]
					--,[CostCenterId]
					,[ProjectId]
					,[T1Id]
					,[T2Id]
					,[T3Id]
					,[MonyId]
			) DrCurr
			Inner JOIn M_ACC_Codes C ON C.Id = DrCurr.CodeId
			Inner JOIn M_ACC_Codes2 C2 ON C2.Mid = C.Id 
				AND 
				(
					(C2.Nature = 0 AND DrCurr.VAL < (-@MaxOnDoc))
					OR
					(C2.Nature = 1 AND DrCurr.VAL > @MaxOnDoc)
				)
			LEFT OUTER JOIN
			(
				SELECT 
					 SUM (DR.Bed+DR.NBed-DR.Bes-DR.NBes) VAL
					,DR.[CodeId]
					--,ISNULL(DR.[CostCenterId],0) [CCId]
					,ISNULL(DR.[ProjectId],0) [PRJId]
					,ISNULL(DR.[T1Id],0) [T1Id]
					,ISNULL(DR.[T2Id],0) [T2Id]
					,ISNULL(DR.[T3Id],0) [T3Id]
					,ISNULL(DR.MonyId,1) MoneyId
				 FROM [dbo].[ACC_AccDocRow] DR
				 Inner JOIN [dbo].ACC_AccDoc D On DR.DId = D.Id
				 Inner JOIn M_ACC_Codes2 C2 ON C2.Mid = DR.CodeId AND C2.Nature in (1,0)
				 Where 
						D.T3Id = @T3Id 
						AND 
						D.Year = @Year 
						AND 
						D.Id <> @DId
						AND 
						( 
							(
								D.DocNo > 0  
								AND 
								D.DocNo < 900000
							) 
						
						)
				 Group by 	
					 DR.[CodeId]
					--,DR.[CostCenterId]
					,DR.[ProjectId]
					,DR.[T1Id]
					,DR.[T2Id]
					,DR.[T3Id]
					,DR.[MonyId]
			) DrOld ON 
				DrCurr.CodeId = DrOld.CodeId
				AND
				--(DrCurr.CCId = DrOld.CCId)
				--AND
				(DrCurr.PRJId = DrOld.PRJId)
				AND
				(DrCurr.T1Id = DrOld.T1Id)
				AND
				(DrCurr.T2Id = DrOld.T2Id)
				AND
				(DrCurr.T3Id = DrOld.T3Id)
				AND
				(DrCurr.MoneyId = DrOld.MoneyId)
			Where 
				(
					(C2.Nature = 0 AND  (ISNULL(DrOld.VAL,0) + DrCurr.VAL) < -@MaxOnAll  )
					OR
					(C2.Nature = 1 AND   (ISNULL(DrOld.VAL,0) + DrCurr.VAL) > @MaxOnAll )
				)		
		end
		
		ELSE
		BEGIN
			Select @Message = @Message + CAST(C.Code AS NVARCHAR) 
				+ N' - ' + C.Name + N' خلاف ماهيت تجميعي:' 
				+ CAST(ABS(DrOld.VAL + DrCurr.VAL) AS NVARCHAR) 
				+SPACE(2)+ CAST(CHAR(13) as NVARCHAR) 
			,@ERRs = @ERRs + 1
			FROM
			(
				SELECT 
					 SUM (Bed+NBed-Bes-NBes) VAL
					,[CodeId]
					--,ISNULL([CostCenterId],0) [CCId]
					,ISNULL([ProjectId],0) [PRJId]
					,ISNULL([T1Id],0) [T1Id]
					--,ISNULL([T2Id],0) [T2Id]
					,ISNULL([T3Id],0) [T3Id]
					,ISNULL(MonyId,1) MoneyId
				 FROM [dbo].[ACC_AccDocRow] 
				 Where DId = @DId
				 Group by 	
					 [CodeId]
					--,[CostCenterId]
					,[ProjectId]
					,[T1Id]
					--,[T2Id]
					,[T3Id]
					,[MonyId]
			) DrCurr
			Inner JOIn M_ACC_Codes C ON C.Id = DrCurr.CodeId
			Inner JOIn M_ACC_Codes2 C2 ON C2.Mid = C.Id 
				AND 
				(
					(C2.Nature = 0 AND DrCurr.VAL < (-@MaxOnDoc))
					OR
					(C2.Nature = 1 AND DrCurr.VAL > @MaxOnDoc)
				)
			LEFT OUTER JOIN
			(
				SELECT 
					 SUM (DR.Bed+DR.NBed-DR.Bes-DR.NBes) VAL
					,DR.[CodeId]
					--,ISNULL(DR.[CostCenterId],0) [CCId]
					,ISNULL(DR.[ProjectId],0) [PRJId]
					,ISNULL(DR.[T1Id],0) [T1Id]
					--,ISNULL(DR.[T2Id],0) [T2Id]
					,ISNULL(DR.[T3Id],0) [T3Id]
					,ISNULL(DR.MonyId,1) MoneyId
				 FROM [dbo].[ACC_AccDocRow] DR
				 Inner JOIN [dbo].ACC_AccDoc D On DR.DId = D.Id
				 Inner JOIn M_ACC_Codes2 C2 ON C2.Mid = DR.CodeId AND C2.Nature in (1,0)
				 Where 
						D.T3Id = @T3Id 
						AND 
						D.Year = @Year 
						AND 
						D.Id <> @DId
						AND 
						( 
							(
								D.DocNo > 0  
								AND 
								D.DocNo < 900000
							) 
						
						)
				 Group by 	
					 DR.[CodeId]
					--,DR.[CostCenterId]
					,DR.[ProjectId]
					,DR.[T1Id]
					--,DR.[T2Id]
					,DR.[T3Id]
					,DR.[MonyId]
			) DrOld ON 
				DrCurr.CodeId = DrOld.CodeId
				--AND
				--(DrCurr.CCId = DrOld.CCId)
				AND
				(DrCurr.PRJId = DrOld.PRJId)
				AND
				(DrCurr.T1Id = DrOld.T1Id)
				--AND
				--(DrCurr.T2Id = DrOld.T2Id)
				AND
				(DrCurr.T3Id = DrOld.T3Id)
				AND
				(DrCurr.MoneyId = DrOld.MoneyId)
			Where 
				(
					(C2.Nature = 0 AND  (DrOld.VAL + DrCurr.VAL) < -@MaxOnAll  )
					OR
					(C2.Nature = 1 AND   (DrOld.VAL + DrCurr.VAL) > @MaxOnAll )
				)		
			
		End	
		
		IF (@ERRs > 0)
		BEGIN
			SET @Message =CAST(CHAR(13) as NVARCHAR)
				+ N'اين سند باعث ايجاد خلاف ماهيت يا افزايش خلاف ماهيت ميشود: '+' '+cast(@did as varchar(10))
				+CAST(CHAR(13) as NVARCHAR) + @Message
			
			INSERT INTO #missingvalue( did,errormessage )
			VALUES( @did ,@Message);	
			
			  --  Select * from #missingvalue
			    	
			Exec dbo.usp_None_Load_RAISERROR @Message
			--print @Message
		END
	end
	--If Aval
	ELSE
		--year 95 and more
	BEGIN

			IF @WithT2 = 1
			Begin
			--add the T2NatureControllerHere

				--If exists (Select * from dbo.ACC_AccDoc Where Id=@DId And DocType in (2,3,7,8,9,10,11))
				--	begin
				--	EXEC [dbo].[USP_ACC_SAVE_T2NatureCtrl] @DId
				--	end
				--With T2
				
				Select @Message = @Message + CAST(C.Code AS NVARCHAR) 
					+ N' - ' + C.Name + N' خلاف ماهيت تجميعي با تفصيل دو ' + CAST(DrCurr.T2Id as NVARCHAR) + N': ' 
					+ CAST(ABS(CAST((ISNULL(DrOld.VAL,0) + DrCurr.VAL)  AS Bigint)) AS NVARCHAR)
					+SPACE(2)+ CAST(CHAR(13) as NVARCHAR) 
				,@ERRs = @ERRs + 1
				FROM
				(
					SELECT 
						 SUM (Bed+NBed-Bes-NBes) VAL
						,[CodeId]
						,ISNULL([CostCenterId],0) [CCId]
						,ISNULL([ProjectId],0) [PRJId]
						,ISNULL([T1Id],0) [T1Id]
						,ISNULL([T2Id],0) [T2Id]
						,ISNULL([T3Id],0) [T3Id]
						,ISNULL(MonyId,1) MoneyId
					 FROM [dbo].[ACC_AccDocRow] 
					 Where DId = @DId
					 Group by 	
						 [CodeId]
						,[CostCenterId]
						,[ProjectId]
						,[T1Id]
						,[T2Id]
						,[T3Id]
						,[MonyId]
				) DrCurr
				Inner JOIn M_ACC_Codes C ON C.Id = DrCurr.CodeId
				Inner JOIn M_ACC_Codes2 C2 ON C2.Mid = C.Id 
					AND 
					(
						(C2.Nature = 0 AND DrCurr.VAL < (-@MaxOnDoc))
						OR
						(C2.Nature = 1 AND DrCurr.VAL > @MaxOnDoc)
					)
				LEFT OUTER JOIN
				(
					SELECT 
						 SUM (DR.Bed+DR.NBed-DR.Bes-DR.NBes) VAL
						,DR.[CodeId]
						,ISNULL(DR.[CostCenterId],0) [CCId]
						,ISNULL(DR.[ProjectId],0) [PRJId]
						,ISNULL(DR.[T1Id],0) [T1Id]
						,ISNULL(DR.[T2Id],0) [T2Id]
						,ISNULL(DR.[T3Id],0) [T3Id]
						,ISNULL(DR.MonyId,1) MoneyId
					 FROM [dbo].[ACC_AccDocRow] DR
					 Inner JOIN [dbo].ACC_AccDoc D On DR.DId = D.Id
					 Inner JOIn M_ACC_Codes2 C2 ON C2.Mid = DR.CodeId AND C2.Nature in (1,0)
					 Where 
							D.T3Id = @T3Id 
							AND 
							D.Year = @Year 
							AND 
							D.Id <> @DId
							AND 
							( 
								(
									D.DocNo > 0  
									AND 
									D.DocNo < 900000
								) 
							
							)
					 Group by 	
						 DR.[CodeId]
						,DR.[CostCenterId]
						,DR.[ProjectId]
						,DR.[T1Id]
						,DR.[T2Id]
						,DR.[T3Id]
						,DR.[MonyId]
				) DrOld ON 
					DrCurr.CodeId = DrOld.CodeId
					AND
					(DrCurr.CCId = DrOld.CCId)
					AND
					(DrCurr.PRJId = DrOld.PRJId)
					AND
					(DrCurr.T1Id = DrOld.T1Id)
					AND
					(DrCurr.T2Id = DrOld.T2Id)
					AND
					(DrCurr.T3Id = DrOld.T3Id)
					AND
					(DrCurr.MoneyId = DrOld.MoneyId)
				Where 
					(
						(C2.Nature = 0 AND  (ISNULL(DrOld.VAL,0) + DrCurr.VAL) < -@MaxOnAll  )
						OR
						(C2.Nature = 1 AND   (ISNULL(DrOld.VAL,0) + DrCurr.VAL) > @MaxOnAll )
					)
			End
		ELSE
			Begin
				Select @Message = @Message + CAST(C.Code AS NVARCHAR) 
					+ N' - ' + C.Name + N' خلاف ماهيت تجميعي:' 
					+ CAST(ABS(DrOld.VAL + DrCurr.VAL) AS NVARCHAR) 
					+SPACE(2)+ CAST(CHAR(13) as NVARCHAR) 
				,@ERRs = @ERRs + 1
				FROM
				(
					SELECT 
						 SUM (Bed+NBed-Bes-NBes) VAL
						,[CodeId]
						,ISNULL([CostCenterId],0) [CCId]
						,ISNULL([ProjectId],0) [PRJId]
						,ISNULL([T1Id],0) [T1Id]
						--,ISNULL([T2Id],0) [T2Id]
						,ISNULL([T3Id],0) [T3Id]
						,ISNULL(MonyId,1) MoneyId
					 FROM [dbo].[ACC_AccDocRow] 
					 Where DId = @DId
					 Group by 	
						 [CodeId]
						,[CostCenterId]
						,[ProjectId]
						,[T1Id]
						--,[T2Id]
						,[T3Id]
						,[MonyId]
				) DrCurr
				Inner JOIn M_ACC_Codes C ON C.Id = DrCurr.CodeId
				Inner JOIn M_ACC_Codes2 C2 ON C2.Mid = C.Id 
					AND 
					(
						(C2.Nature = 0 AND DrCurr.VAL < (-@MaxOnDoc))
						OR
						(C2.Nature = 1 AND DrCurr.VAL > @MaxOnDoc)
					)
				LEFT OUTER JOIN
				(
					SELECT 
						 SUM (DR.Bed+DR.NBed-DR.Bes-DR.NBes) VAL
						,DR.[CodeId]
						,ISNULL(DR.[CostCenterId],0) [CCId]
						,ISNULL(DR.[ProjectId],0) [PRJId]
						,ISNULL(DR.[T1Id],0) [T1Id]
						--,ISNULL(DR.[T2Id],0) [T2Id]
						,ISNULL(DR.[T3Id],0) [T3Id]
						,ISNULL(DR.MonyId,1) MoneyId
					 FROM [dbo].[ACC_AccDocRow] DR
					 Inner JOIN [dbo].ACC_AccDoc D On DR.DId = D.Id
					 Inner JOIn M_ACC_Codes2 C2 ON C2.Mid = DR.CodeId AND C2.Nature in (1,0)
					 Where 
							D.T3Id = @T3Id 
							AND 
							D.Year = @Year 
							AND 
							D.Id <> @DId
							AND 
							( 
								(
									D.DocNo > 0  
									AND 
									D.DocNo < 900000
								) 
							
							)
					 Group by 	
						 DR.[CodeId]
						,DR.[CostCenterId]
						,DR.[ProjectId]
						,DR.[T1Id]
						--,DR.[T2Id]
						,DR.[T3Id]
						,DR.[MonyId]
				) DrOld ON 
					DrCurr.CodeId = DrOld.CodeId
					AND
					(DrCurr.CCId = DrOld.CCId)
					AND
					(DrCurr.PRJId = DrOld.PRJId)
					AND
					(DrCurr.T1Id = DrOld.T1Id)
					--AND
					--(DrCurr.T2Id = DrOld.T2Id)
					AND
					(DrCurr.T3Id = DrOld.T3Id)
					AND
					(DrCurr.MoneyId = DrOld.MoneyId)
				Where 
					(
						(C2.Nature = 0 AND  (DrOld.VAL + DrCurr.VAL) < -@MaxOnAll  )
						OR
						(C2.Nature = 1 AND   (DrOld.VAL + DrCurr.VAL) > @MaxOnAll )
					)
			End
				IF (@ERRs > 0)
				BEGIN
					SET @Message =CAST(CHAR(13) as NVARCHAR)
						+ N'اين سند باعث ايجاد خلاف ماهيت يا افزايش خلاف ماهيت ميشود: '+' ' +cast(@did as varchar(10))
						+CAST(CHAR(13) as NVARCHAR) + @Message
						
				
					    	
					Exec dbo.usp_None_Load_RAISERROR @Message
					
					
				END
			
	END

END

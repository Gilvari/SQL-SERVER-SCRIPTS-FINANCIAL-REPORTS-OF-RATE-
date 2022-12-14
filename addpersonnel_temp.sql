/*
	Author:		B.Fallah
	Date:		2016-07-02
*/
Create PROCEDURE [dbo].[usp_ORG_Save_Personnel_temp] 
	  @UserId int, -- Editor Or Creator ID
	  @Id int= NULL, @T3Id int= NULL, @FirstName nvarchar(100)= NULL, @LastName nvarchar(100)= NULL, @T1Id int= NULL, @OrgUnitId int= NULL, @PersonnelTypeIndex tinyint= NULL, @OrgPostId int= NULL, @AccessLevel nvarchar(1000)= NULL, @UserName nvarchar(50)= NULL, @Password nvarchar(350)= NULL, @FileNo nvarchar(50)= NULL, @PersonnelCode nvarchar(50)= NULL, @NationalCode varchar(15)= NULL, @FatherName nvarchar(50)= NULL, @BirthDate smalldatetime= NULL, @IdNo varchar(10)= NULL, @GenderIndex tinyint= NULL, @MarriageStatusIndex tinyint= NULL, @EducationalLevelId tinyint= NULL, @EducationalFieldId smallint= NULL, @CreditRowId int= NULL, @CreditProgramId int= NULL,
	  --	@BankNameId tinyint = NULL,
	  @BankNameId int= NULL,
	  --	@BankBranch nvarchar(50) = NULL,
	  @BankAccountNo varchar(50)= NULL, @ChildNumber tinyint= NULL, @ActiveStatusIndex tinyint= NULL, @EmploymentTypeId tinyint= NULL, @EmploymentClassId smallint= NULL, @InsuranceTypeId tinyint= NULL, @InsurancePlaceId int= NULL, @PersonnelImage varbinary(max)= NULL, @InsuranceCode varchar(8)= '', @UpdateImage bit= 0, @SelectAndReturnData bit= 1, @EmploymentDate smalldatetime= NULL, @IdShire tinyint= NULL, @IdCity tinyint= NULL, @IdEL tinyint= NULL, @ConscriptKindIndex tinyint= NULL, @SalaryStatusKindIndex tinyint= NULL, @IdSerial int= NULL, @EmpGroupCode smallint= NULL, @ItemList varchar(max)= NULL, -- SLARYITEMIDs
	  @SaveTypeList varchar(max)= NULL, @InsurTypeList varchar(max)= NULL
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		IF(@T3Id < 1)
		BEGIN
			SET @T3Id = NULL;
		END;
		IF( @T3Id IS NULL
		  )
		BEGIN
			EXEC dbo.usp_None_Load_RAISERROR N'شناسه مركز معتبر نيست.';
		END;
		IF( @FirstName IS NOT NULL
		  )
		BEGIN
			SET @FirstName = dbo.UF_YK_Replacer( @FirstName );
		END;
		IF( @LastName IS NOT NULL
		  )
		BEGIN
			SET @LastName = dbo.UF_YK_Replacer( @LastName );
		END;
		IF( @UserName IS NOT NULL
		  )
		BEGIN
			SET @UserName = dbo.UF_YK_Replacer( @UserName );
		END;
		IF( @FatherName IS NOT NULL
		  )
		BEGIN
			SET @FatherName = dbo.UF_YK_Replacer( @FatherName );
		END;

		IF(@T1Id < 1)
		BEGIN
			SET @T1Id = NULL;
		END;
		IF(@OrgUnitId < 1)
		BEGIN
			SET @OrgUnitId = NULL;
		END;
		IF(@OrgPostId < 1)
		BEGIN
			SET @OrgPostId = NULL;
		END;
		IF(@EducationalLevelId < 1)
		BEGIN
			SET @EducationalLevelId = NULL;
		END;
		IF(@EducationalFieldId < 1)
		BEGIN
			SET @EducationalFieldId = NULL;
		END;
		IF(@CreditRowId < 1)
		BEGIN
			SET @CreditRowId = NULL;
		END;
		IF(@CreditProgramId < 1)
		BEGIN
			SET @CreditProgramId = NULL;
		END;
		IF(@BankNameId < 1)
		BEGIN
			SET @BankNameId = NULL;
		END;
		IF(@EmploymentTypeId < 1)
		BEGIN
			SET @EmploymentTypeId = NULL;
		END;
		IF(@EmploymentClassId < 1)
		BEGIN
			SET @EmploymentClassId = NULL;
		END;
		IF(@InsuranceTypeId < 1)
		BEGIN
			SET @InsuranceTypeId = NULL;
		END;
		IF(@InsurancePlaceId < 1)
		BEGIN
			SET @InsurancePlaceId = NULL;
		END;


		IF(ISNULL(@Password, 'Do not change this') <> 'Do not change this') -- NOT From T1 Editing
		BEGIN
			DECLARE @NewT1Id int;
			SET @NewT1Id = -1;
			DECLARE @T1Index tinyint;
			SET @T1Index = 2;
			DECLARE @NFT1 nvarchar(500);
			SET @NFT1 = ( @FirstName+' '+@LastName );
			EXEC [dbo].[usp_ACC_Save_T1_FromSPs] @NationalCode, @NFT1, @T1Id, @T1Index, @UserId, @T3Id, @NewT1Id OUTPUT, 1;
			IF( @NewT1Id IS NULL OR 
				@NewT1Id < 1
			  )
			BEGIN
				EXEC dbo.usp_None_Load_RAISERROR N'امکان ساخت تفصيل يک با اطلاعات وارد شده براي پرسنل وجود ندارد';
				RETURN;
			END;
			SET @T1Id = @NewT1Id;
		END;

		IF(ISNULL(@Id, 0) < 1)
		BEGIN
			IF( @OrgUnitId IS NULL AND 
				@UserId > 0
			  )
			BEGIN
				IF(@Password = 'Do not change this')
				BEGIN
					RETURN;
				END;
				EXEC dbo.usp_None_Load_RAISERROR N'واحد سازمانی انتخابی معتبر نيست.';
				RETURN;
			END;
			IF( @EmploymentDate IS NULL
			  )
			BEGIN
				SET @EmploymentDate = '1900/01/01';
			END;
			IF( @IdShire IS NULL
			  )
			BEGIN
				SET @IdShire = 0;
			END;
			IF( @IdCity IS NULL
			  )
			BEGIN
				SET @IdCity = 0;
			END;
			IF( @IdEL IS NULL
			  )
			BEGIN
				SET @IdEL = 0;
			END;
			IF( @ConscriptKindIndex IS NULL
			  )
			BEGIN
				SET @ConscriptKindIndex = 0;
			END;
			IF( @SalaryStatusKindIndex IS NULL
			  )
			BEGIN
				SET @SalaryStatusKindIndex = 0;
			END;
			IF( @IdSerial IS NULL
			  )
			BEGIN
				SET @IdSerial = 0;
			END;
			INSERT INTO [dbo].[ORG_Personnel]( [T3Id], [FirstName], [LastName], [T1Id], [OrgUnitId], [PersonnelTypeIndex], [OrgPostId], [AccessLevel], [UserName], [Password], [FileNo], [PersonnelCode], [NationalCode], [FatherName], [BirthDate], [IdNo], [GenderIndex], [MarriageStatusIndex], [EducationalLevelId], [EducationalFieldId], [CreditRowId], [CreditProgramId], [BankNameId], [BankAccountNo], [ChildNumber], [ActiveStatusIndex], [EmploymentTypeId], [EmploymentClassId], [InsuranceTypeId], [InsurancePlaceId], [InsuranceCode], [EmploymentDate], [IdShire], [IdCity], [IdEL], [ConscriptKindIndex], [SalaryStatusKindIndex], [IdSerial], [EmpGroupCode] )
			VALUES( @T3Id, @FirstName, @LastName, @T1Id, @OrgUnitId, @PersonnelTypeIndex, @OrgPostId, @AccessLevel, @UserName, @Password, @FileNo, @PersonnelCode, @NationalCode, @FatherName, @BirthDate, @IdNo, @GenderIndex, @MarriageStatusIndex, @EducationalLevelId, @EducationalFieldId, @CreditRowId, @CreditProgramId, @BankNameId, @BankAccountNo, @ChildNumber, @ActiveStatusIndex, @EmploymentTypeId, @EmploymentClassId, @InsuranceTypeId, @InsurancePlaceId, @InsuranceCode, @EmploymentDate, @IdShire, @IdCity, @IdEL, @ConscriptKindIndex, @SalaryStatusKindIndex, @IdSerial, @EmpGroupCode );
			SET @Id = SCOPE_IDENTITY();
		END;
		ELSE
		BEGIN
			IF( @SelectAndReturnData = 0 AND 
				@Password = 'Do not change this'
			  )	-- From T1 Editing
			BEGIN
				SET @FirstName = LTRIM(RTRIM(ISNULL(@FirstName, '')));
				DECLARE @IndexOfSpace int;
				SET @IndexOfSpace = CHARINDEX(' ', @FirstName);
				IF(@IndexOfSpace > 0)
				BEGIN
					SET @LastName = SUBSTRING(@FirstName, @IndexOfSpace+1, LEN(@FirstName)-@IndexOfSpace);
					SET @FirstName = SUBSTRING(@FirstName, 1, @IndexOfSpace-1);
				END;
				ELSE
				BEGIN
					SET @FirstName = NULL;
				END;
				UPDATE [dbo].[ORG_Personnel]
				  SET [FirstName] = ISNULL(@FirstName, [FirstName]), [LastName] = ISNULL(@LastName, [LastName]), [NationalCode] = ISNULL(@NationalCode, [NationalCode])
				--,@OrgUnitId = [OrgUnitId]
				WHERE( Id = @Id AND 
					   T3Id = @T3Id
					 );
			END;
			ELSE
			BEGIN
				UPDATE [dbo].[ORG_Personnel]
				  SET [FirstName] = ISNULL(@FirstName, [FirstName]), [LastName] = ISNULL(@LastName, [LastName]), [T1Id] = ISNULL(@T1Id, [T1Id]), @OrgUnitId = ISNULL(@OrgUnitId, [OrgUnitId]), [OrgUnitId] = ISNULL(@OrgUnitId, [OrgUnitId]), [PersonnelTypeIndex] = ISNULL(@PersonnelTypeIndex, [PersonnelTypeIndex]), [OrgPostId] = ISNULL(@OrgPostId, [OrgPostId]), [AccessLevel] = ISNULL(@AccessLevel, [AccessLevel]), [UserName] = ISNULL(@UserName, [UserName]), [Password] = ISNULL(@Password, [Password]), [FileNo] = ISNULL(@FileNo, [FileNo]), [PersonnelCode] = ISNULL(@PersonnelCode, [PersonnelCode]), [NationalCode] = ISNULL(@NationalCode, [NationalCode]), [FatherName] = ISNULL(@FatherName, [FatherName]), [BirthDate] = ISNULL(@BirthDate, [BirthDate]), [IdNo] = ISNULL(@IdNo, [IdNo]), [GenderIndex] = ISNULL(@GenderIndex, [GenderIndex]), [MarriageStatusIndex] = ISNULL(@MarriageStatusIndex, [MarriageStatusIndex]), [EducationalLevelId] = ISNULL(@EducationalLevelId, [EducationalLevelId]), [EducationalFieldId] = ISNULL(@EducationalFieldId, [EducationalFieldId]), [CreditRowId] = ISNULL(@CreditRowId, [CreditRowId]), [CreditProgramId] = ISNULL(@CreditProgramId, [CreditProgramId]), [BankNameId] = ISNULL(@BankNameId, [BankNameId]), [BankAccountNo] = ISNULL(@BankAccountNo, [BankAccountNo]), [ChildNumber] = ISNULL(@ChildNumber, [ChildNumber]), [ActiveStatusIndex] = ISNULL(@ActiveStatusIndex, [ActiveStatusIndex]), [EmploymentTypeId] = ISNULL(@EmploymentTypeId, [EmploymentTypeId]), [EmploymentClassId] = ISNULL(@EmploymentClassId, [EmploymentClassId]), [InsuranceTypeId] = ISNULL(@InsuranceTypeId, [InsuranceTypeId]), [InsurancePlaceId] = ISNULL(@InsurancePlaceId, [InsurancePlaceId]), [InsuranceCode] = ISNULL(@InsuranceCode, [InsuranceCode]), [EmploymentDate] = ISNULL(@EmploymentDate, [EmploymentDate]), [IdShire] = ISNULL(@IdShire, [IdShire]), [IdCity] = ISNULL(@IdCity, [IdCity]), [IdEL] = ISNULL(@IdEL, [IdEL]), [ConscriptKindIndex] = ISNULL(@ConscriptKindIndex, [ConscriptKindIndex]), [SalaryStatusKindIndex] = ISNULL(@SalaryStatusKindIndex, [SalaryStatusKindIndex]), [IdSerial] = ISNULL(@IdSerial, [IdSerial]), [EmpGroupCode] = ISNULL(@EmpGroupCode, [EmpGroupCode])
				WHERE( Id = @Id AND 
					   T3Id = @T3Id
					 );
				IF(@@ROWCOUNT > 0)
				BEGIN
					UPDATE T1
					  SET T1.Code = ( '2-'+P.NationalCode ), T1.Name = P.FullName
					FROM ACC_T1 T1
						 INNER JOIN
						 [dbo].[ORG_Personnel] P
						 ON T1.Id = P.T1Id
					WHERE P.Id = @Id;
				END;
			END;
		END;
		IF(@UpdateImage = 1)
		BEGIN
			UPDATE [dbo].[ORG_Personnel]
			  SET PersonnelImage = @PersonnelImage
			WHERE(Id = @Id);
			EXEC [dbo].[usp_None_Save_UniqueCacheDataWithoutCheck] @TypeId = 102, @T3ID = -100, @LevelId = -100, @ParentId = @Id, @Etc = 0;
		END;

		IF @ItemList IS NOT NULL
		BEGIN
			DELETE FROM dbo.PYRL2_Personnel_Items
			WHERE PId = @Id;
			IF LEN(@ItemList) > 0
			BEGIN
				DECLARE @STRITEMS varchar(max);
				SET @STRITEMS = 'INSERT INTO [dbo].[PYRL2_Personnel_Items]
					   ([T3Id]
					   ,[PId]
					   ,[ItemId])
				 Select 
						'+CAST(@T3Id AS varchar)+' AS [T3Id]
					   ,'+CAST(@Id AS varchar)+'	 AS [PId]
					   ,Id	AS [ItemId]
				From  dbo.PYRL2_Items
				Where Id in ('+@ItemList+')';
				EXEC (@STRITEMS);
			END;
		END;
		IF @InsurTypeList IS NOT NULL
		BEGIN
			DELETE FROM dbo.PYRL2_Personnel_InsurTypes
			WHERE PId = @Id;
			IF LEN(@InsurTypeList) > 0
			BEGIN
				DECLARE @STRITypes varchar(max);
				SET @STRITypes = 'INSERT INTO [dbo].[PYRL2_Personnel_InsurTypes]
					   ([T3Id]
					   ,[PId]
					   ,[ITypeId])
				 Select 
						'+CAST(@T3Id AS varchar)+' AS [T3Id]
					   ,'+CAST(@Id AS varchar)+'	 AS [PId]
					   ,Id	AS [ITypeId]
				From  dbo.PYRL2_InsurTypes
				Where Id in ('+@InsurTypeList+')';
				EXEC (@STRITypes);
			END;
		END;
		IF @SaveTypeList IS NOT NULL
		BEGIN
			DELETE FROM dbo.PYRL2_Personnel_SaveTypes
			WHERE PId = @Id;
			IF LEN(@SaveTypeList) > 0
			BEGIN
				DECLARE @STRSTypes varchar(max);
				SET @STRSTypes = 'INSERT INTO dbo.PYRL2_Personnel_SaveTypes
					   ([T3Id]
					   ,[PId]
					   ,[STypeId])
				 Select 
						'+CAST(@T3Id AS varchar)+' AS [T3Id]
					   ,'+CAST(@Id AS varchar)+'	 AS [PId]
					   ,Id	AS [STypeId]
				From  dbo.PYRL2_SaveTypes
				Where Id in ('+@SaveTypeList+')';
				EXEC (@STRSTypes);
			END;
		END;
		EXEC [dbo].[USP_ORG_SAVE_SetStaffPASS];



		IF(@SelectAndReturnData = 1)
		BEGIN
			SELECT @Id AS Id;
		END;
	END TRY
	-------------------------------------------------------------
	BEGIN CATCH
		CREATE TABLE #missingvalue
		( 
					 nationalcode nvarchar(10),
					 errormessage nvarchar(1000)
		);

		IF ERROR_MESSAGE() LIKE '%IX_ORG_P_UNI_UserNameAtT3%'
		BEGIN
			DECLARE @ErrMsg nvarchar(1000);
			SET @ErrMsg = ERROR_MESSAGE()+CHAR(13)+CHAR(10)+'نام کاربری با کدملی '+@NationalCode+'تکراری است';
			RAISERROR(@ErrMsg, 16, 2);
			INSERT INTO #missingvalue( NationalCode ,errormessage)
			VALUES( @NationalCode ,@ErrMsg);
		END;
		Else
		
		IF ERROR_MESSAGE() LIKE '%IX_ORG_Personnel_T1Id%'
		BEGIN
			DECLARE @ErrMsg2 nvarchar(1000);
			SET @ErrMsg2 = ERROR_MESSAGE()+CHAR(13)+CHAR(10)+'این تفصیل 1 قبلا ایجاد شده است'
			RAISERROR(@ErrMsg2, 16, 2);
		
		END;
		Else
		
		IF ERROR_MESSAGE() LIKE '%IX_ORG_P_NCAtT3Id%'
		BEGIN
			DECLARE @ErrMsg3 nvarchar(1000);
			SET @ErrMsg3 = ERROR_MESSAGE()+CHAR(13)+CHAR(10)+'فرد دیگری در این مرکز با کد ملی '+@NationalCode+'وجود دارد'
			RAISERROR(@ErrMsg3, 16, 2);
						INSERT INTO #missingvalue( NationalCode,errormessage )
			VALUES( @NationalCode ,@ErrMsg3);
		End
		
		Else	
		
	   IF ERROR_MESSAGE() LIKE '%IX_ACC_T1UniqueNameAtT3AndFolderIndex%'
		BEGIN
			DECLARE @ErrMsg4 nvarchar(1000);
			SET @ErrMsg4 = ERROR_MESSAGE()+CHAR(13)+CHAR(10)+'نام و نام خانوادگی کد ملی  '+@NationalCode+'در این مرکز تکرای است'
			RAISERROR(@ErrMsg4, 16, 2);
						INSERT INTO #missingvalue( NationalCode,errormessage )
			VALUES( @NationalCode ,@ErrMsg4);
			
			--------در صورتی که بخواهیم مشکل تکراری بودن نام و نام خانوادگی را حل کنیم می توانیم به نام حانوادگی "." اضافه کنیم-------
			set @LastName=@LastName+N'.'
	exec USP_ORG_SAVE_PERSONNEL_temp @userid=@UserId,@id=-1,@orgunitid=@OrgUnitId,@t3id=@T3Id,@FirstName=@FirstName,@LastName=@LastName,@T1Id=-1,@AccessLevel=N'OSNtC1SVYWepdwgI4iDMHs3p6plfugRvCd8nzsDcKbP1iX36/oxYsiN/FgJEh2EGT20ZmtjT+kOaYqU+yL/PWF1hlym9owkkGX7ON/nT0d0Fxac0Nz1u07eqjx8RiuX82daSCbIqRCh0y8Fhq+t95A==',@UserName=@UserName,@Password=N'1',@NationalCode=@NationalCode
		
			----------------------------
		END;
		
	SELECT *
	FROM #missingvalue;
	END CATCH;


END;
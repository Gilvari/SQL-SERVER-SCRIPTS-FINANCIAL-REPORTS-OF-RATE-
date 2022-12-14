ALTER PROCEDURE [dbo].[usp_STK_Save_Provider]
	 @UserId int
	,@Id int
	,@T3Id int
	,@Code Varchar(20)
	,@Name NVarchar(150)
	,@FolderId Int
	,@Address nvarchar(250)
	,@EconomicCode nvarchar(20)
	,@NationalCode varchar(15)
	,@PostCode varchar(15)
	,@ActingTypeId int
	,@Tel1 varchar(50)
	,@Tel2 varchar(50)
	,@Mobile varchar(50)
	,@Fax varchar(50)
	,@Connector nvarchar(100)
AS
BEGIN
	Set NoCount ON	
	declare @T3IdPublic INT
	--declare @T1Id INT
	--Select @T1Id = Id from ACC_T1 T1
	-- WHERE (T1.[Name] = @Name OR T1.[Code] = @Code)AND T1.[T3Id] = @T3Id
	
	if (@Id < 1) 
		BEGIN
			Select @Name = dbo.UF_YK_Replacer (@Name)
			Declare @NameChanged bit,@CodeChanged bit,@CodeIndex tinyInt
			if (CharIndex('-',@Code) = 0)   
				Select @Code =  (Cast(F.IndexForCodingObjects as varchar) + '-' + @Code)
				From dbo.PUB_Folders AS F Where F.Id = @FolderId
			SELECT 
				 @Id = T1.Id 
				,@NameChanged = Case When T1.[Name] = @Name Then 0 Else 1 END 
				,@CodeChanged = Case When T1.[Code] = @Code Then 0 Else 1 END
				--,@T3IdPublic = Case When @T1Id Is null then @T3Id 
				--                 else
				--                   Case when T1.[T3Id] is null then null Else @T3Id 
				--                  END 
				--                 END
			FROM dbo.ACC_T1 AS T1
			WHERE (	T1.[Name] = @Name 
					OR
					T1.[Code]  = @Code)	 
				AND
					T1.[T3Id] = @T3Id
		END
	if (ISNULL(@Id,-1) < 1)
		BEGIN
			INSERT INTO dbo.ACC_T1
				(
				Code, 
				[Name], 
				FolderId, 
				T3Id
				)
			VALUES     
				(
				@Code, 
				@Name, 
				@FolderId, 
				@T3Id
				)
			Set @Id = scope_identity()
			Declare @ETC bigint
			Select @ETC = [dbo].[UF_Pub_IdETCCreatorForList] (@Id)
			Exec [dbo].[usp_PUB_Save_CacheData] 8,@T3Id,@FolderId,-100,@UserId,@ETC
		END
--	if (@T3Id < 1) set @T3Id = null
	if (@ActingTypeId < 1) set @ActingTypeId = null

	Select @Address =  [dbo].[UF_YK_Replacer] (@Address)
			,@EconomicCode = [dbo].[UF_YK_Replacer] (@EconomicCode)
			,@Connector = [dbo].[UF_YK_Replacer] (@Connector)
	IF Exists (Select Id From [dbo].[STK_Providers] WHERE Id = @Id)
		Begin
			Update [dbo].[STK_Providers] Set
				 [Address]=@Address
				,[EconomicCode]=@EconomicCode
				,[NationalCode]=@NationalCode
				,[PostCode]=@PostCode
				,[ActingTypeId]=@ActingTypeId
				,[Tel1]=@Tel1
				,[Tel2]=@Tel2
				,[Mobile]=@Mobile
				,[Fax]=@Fax
				,[Connector]=@Connector
			Where (Id= @Id)
		END
	else
		BEGIN
			SELECT @T3IdPublic = T3Id FROM dbo.ACC_T1 WHERE Id = @Id
			INSERT INTO [dbo].[STK_Providers]
				([Id]
				,[T3Id]
				,[Address]
				,[EconomicCode]
				,[NationalCode]
				,[PostCode]
				,[ActingTypeId]
				,[Tel1]
				,[Tel2]
				,[Mobile]
				,[Fax]
				,[Connector])
			VALUES
				(@Id
				,CASE WHEN @T3IdPublic IS NULL THEN NULL ELSE @T3Id END
				,@Address
				,@EconomicCode
				,@NationalCode
				,@PostCode
				,@ActingTypeId
				,@Tel1
				,@Tel2
				,@Mobile
				,@Fax
				,@Connector)
		END
	Exec [dbo].[usp_PUB_Save_CacheData] 57,@T3Id,@ActingTypeId,-100,@UserId
	Select * From dbo.UV_STK_Providers Where Id = @Id
END

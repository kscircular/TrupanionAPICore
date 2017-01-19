USE [Trupanion]
GO
/****** Object:  StoredProcedure [dbo].[AddPet]    Script Date: 1/18/2017 9:37:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AddPet] (@PetOwnerId INT, @Name VARCHAR(40), @DateOfBirth DateTime, @BreedName NVARCHAR(40))
AS
/*=============================================================
  AddPet    
  =============================================================  
  Example:
  DECLARE @PetOwnerId INT
  DECLARE @Name VARCHAR(40)
  DECLARE @DateOfBirth DATETIME
  DECLARE @BreedName nVARCHAR(40)

  SET @PetOwnerId=2
  SET @Name='Blinky'
  SET @DateOfBirth=GetDate()
  SET @BreedName='Mixe1d'

  BEGIN TRAN
  SELECT P.* FROM Pet P INNER JOIN PetOwner PO on P.PetOwnerId=PO.Id
    where P.Name=@Name

  EXEC [AddPet] @PetOwnerId, @Name, @DateOfBirth, @BreedName

  SELECT P.* FROM Pet P INNER JOIN PetOwner PO on P.PetOwnerId=PO.Id
    where P.Name=@Name

  ROLLBACK TRAN
  =============================================================*/

BEGIN
 SET NOCOUNT ON
 BEGIN TRY
    DECLARE @BreedId INT;

	IF (NOT EXISTS(SELECT * FROM dbo.PetOwner WHERE Id=@PetOwnerId))
		RAISERROR('Pet Owner does not exist!',16,1);

    IF (EXISTS(SELECT * FROM Pet P INNER JOIN PetOwner PO on P.PetOwnerId=PO.Id
	  WHERE P.Name=@Name))	RAISERROR('Pet already exists!',16,1);

	SELECT @BreedId=Id FROM Breed WHERE Name=@BreedName

	IF (@BreedId IS NULL) RAISERROR('Invalid Breed Name specified.',16,1);

	BEGIN TRANSACTION
    
	INSERT INTO Pet(PetOwnerId, Name,DateOfBirth,BreedId)
	VALUES (@PetOwnerId, @Name,@DateOfBirth,@BreedId)
		 
	COMMIT TRANSACTION

	END TRY
	BEGIN CATCH
		IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
		DECLARE @MSG VARCHAR(300)
		SET @MSG='Specified pet could not be added to the policy. '+ERROR_MESSAGE()
		RAISERROR (@MSG,16,1)
	END CATCH

END





GO
/****** Object:  StoredProcedure [dbo].[Cancel]    Script Date: 1/18/2017 9:37:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[Cancel] (@PolicyNumber VARCHAR(13))
AS
/*=============================================================
  Cancel    
  =============================================================  
  Example:
  DECLARE @PolicyNumber VARCHAR(13)
  SET @PolicyNumber='"US0000000038'
  EXEC [Cancel] @PolicyNumber
  =============================================================*/

BEGIN
 SET NOCOUNT ON
 BEGIN TRY
	IF (NOT EXISTS(SELECT * FROM dbo.PetOwner WHERE PolicyNumber=@PolicyNumber))
		RAISERROR('Policy does not exist!',10,1);

	BEGIN TRANSACTION

	 UPDATE PetOwner
	 SET PolicyNumber=''
	 WHERE PolicyNumber=@PolicyNumber
	 
	COMMIT TRANSACTION

	END TRY
	BEGIN CATCH
		IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION

		DECLARE @MSG VARCHAR(300)
		SET @MSG='Could not cancel specified policy.'+ERROR_MESSAGE()
		RAISERROR (@MSG,16,1)
	END CATCH

END





GO
/****** Object:  StoredProcedure [dbo].[Enroll]    Script Date: 1/18/2017 9:37:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[Enroll] (@PetOwnerId INT, @CountryCode CHAR(3))
AS
/*=============================================================
  Entroll    
  =============================================================
   
  Example:
  DECLARE @PetOwnerId INT
  SET @PetOwnerId=1
  DECLARE @CountryCode CHAR(3)
  SET @CountryCode='USA'

  EXEC [Enroll] @PetOwnerId,@CountryCode
  =============================================================*/

BEGIN
 SET NOCOUNT ON
 BEGIN TRY
	IF (NOT EXISTS(SELECT * FROM dbo.PetOwner WHERE Id=@PetOwnerId))
		RAISERROR('Pet Owner does not exist!',10,1);

	BEGIN TRANSACTION
	 DECLARE @PolicyNumber VARCHAR(13)
	 SET @PolicyNumber=''

	 Exec [GeneratePolicyNumber] @PetOwnerId, @CountryCode,@PolicyNumber OUTPUT

	 UPDATE PetOwner
	 SET PolicyNumber=@PolicyNumber
	 WHERE Id=@PetOwnerId
	 
	COMMIT TRANSACTION

	END TRY
	BEGIN CATCH
		IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION

		DECLARE @MSG VARCHAR(300)
		SET @MSG='Could not enroll pet owner: '+ERROR_MESSAGE()
		RAISERROR (@MSG,16,1)
	END CATCH

END




GO
/****** Object:  StoredProcedure [dbo].[GeneratePolicyNumber]    Script Date: 1/18/2017 9:37:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GeneratePolicyNumber](@PetOwnerID INT,@CountryCode CHAR(3)='USA',@PolicyNumber CHAR(13) OUTPUT)
AS
/*=============================================================
  GeneratePolicyNumber      
  =============================================================
  Generates a unique policy number. When generated the policy number
  table can also be used a nexus for queries that relate to 
  PolicyNumbers and PetOwnerIds.
  
  Example:
  DECLARE @PetOwnerID INT
  SET @PetOwnerID=1
  DECLARE @CountryCode CHAR(3)
  SET @CountryCode='USA'
  DECLARE @PolicyNumber CHAR(13)
  SET @PolicyNumber=''
  EXEC GeneratePolicyNumber @PetOwnerId,@CountryCode,@PolicyNumber OUTPUT
  SELECT @PolicyNumber 'PolicyNumber'


  =============================================================*/
BEGIN TRANSACTION
	SET NOCOUNT ON
	DECLARE @Id INT
	DECLARE @StrID VARCHAR(13)
	DECLARE @Inserted table (id int);

	/* NOTE: For brevity I left out the parameter checking.  In practive I would include
	 these checks are well as wrap the sproc in a TRY/CATCH block.
	 This sproc uses a technique of grabbing the ACTUAL ID of the Identity column
	 inserted instead of SCOPE_IDENTITY and IDENT_CURRENT.  The former is better than
	 @@IDENTITY but does not work with there is a back-end trigger firing in the same scope.
	*/
 SET NOCOUNT ON
 BEGIN TRY
	INSERT INTO PolicyNumbers(PolicyNumber,PetOwnerId)
	OUTPUT inserted.Id INTO @Inserted
	VALUES('',@PetOwnerId) 

	SELECT @Id=id from @Inserted;
	SET @StrID=CAST(@ID AS VARCHAR(13))
    SET @PolicyNumber=@CountryCode+REPLICATE('0',10-LEN(@StrID))+@StrId

	UPDATE PolicyNumbers
	SET PolicyNumber=@PolicyNumber
	WHERE Id=@Id

	--Return PolicyNumber
	SET @PolicyNumber=@PolicyNumber

	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION

		DECLARE @MSG VARCHAR(300)
		SET @MSG='Could not enroll pet owner.'+ERROR_MESSAGE()
		RAISERROR (@MSG,16,1)
	END CATCH


GO
/****** Object:  StoredProcedure [dbo].[RemovePet]    Script Date: 1/18/2017 9:37:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[RemovePet] (@PetOwnerId INT, @PetId INT)
AS
/*=============================================================
  Cancel    
  =============================================================  
  Example:
  DECLARE @PetOwnerId INT
  DECLARE @PetId INT
  SET @PetOwnerId=1
  SET @PetId=1
  EXEC [RemovePet] @PetOwnerId,@PetId
  =============================================================*/

BEGIN
 SET NOCOUNT ON
 BEGIN TRY
	IF (NOT EXISTS(SELECT * FROM dbo.PetOwner WHERE Id=@PetOwnerId))
		RAISERROR('Pet Owner does not exist!',10,1);

	BEGIN TRANSACTION

	DELETE P
	FROM PetOwner PO INNER JOIN Pet P ON PO.Id=P.PetOwnerId
	WHERE PO.Id=@PetOwnerId and P.Id=@PetId
	 
	COMMIT TRANSACTION

	END TRY
	BEGIN CATCH
		IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION

		DECLARE @MSG VARCHAR(300)
		SET @MSG='Specified pet could not be removed from policy.'+ERROR_MESSAGE()
		RAISERROR (@MSG,16,1)
	END CATCH

END





GO
/****** Object:  StoredProcedure [dbo].[TransferPetOwnership]    Script Date: 1/18/2017 9:37:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TransferPetOwnership] (@OriginalOwnerId Int, @NewOwnerId INT)
AS
/*=============================================================
  TransferPetOwnership      
  =============================================================
  Transfer ownership from one owner to another.
  
  Example:
  DECLARE @OriginalOwnerId INT
  SET @OriginalOwnerID=1
  DECLARE @NewOwnerId INT
  SET @NewOwnerId=2

  /*Before*/
  SELECT 'BEFORE',* FROM Pet WHERE PetOwnerId=@OriginalOwnerId
  EXEC [TransferPetOwnership] @OriginalOwnerId,@NewOwnerId 
  /*After*/
  SELECT 'AFTER',* FROM Pet WHERE PetOwnerId=@NewOwnerId

  =============================================================*/

BEGIN
 SET NOCOUNT ON
 BEGIN TRY
	IF (NOT EXISTS(SELECT * FROM dbo.PetOwner WHERE Id=@OriginalOwnerId))
		RAISERROR('Original Owner ID does not exist',10,1);

	IF (NOT EXISTS(SELECT * FROM dbo.PetOwner WHERE Id=@OriginalOwnerId))
	   BEGIN
	    SELECT 'HERE'
		RAISERROR('Original Owner does not have any pets to transfer.',10,1);
	   END
 
	IF (NOT EXISTS(SELECT * FROM dbo.PetOwner WHERE Id=@NewOwnerId))
		RAISERROR('New Owner ID does not exist',10,1);

	BEGIN TRANSACTION

	/*Insert the transferred pets into the Pet table*/
	INSERT INTO dbo.Pet(PetOwnerId,Name,DateOfBirth,BreedId)
	SELECT @NewOwnerId,Name,DateOfBirth,BreedId
	FROM Pet
	WHERE PetOwnerId=@OriginalOwnerId

	/*Delete the Pets for the former owner*/
	DELETE FROM Pet
	WHERE PetOwnerId=@OriginalOwnerId

	COMMIT TRANSACTION

	END TRY
	BEGIN CATCH
		IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION

		DECLARE @MSG VARCHAR(300)
		SET @MSG='Could not perform ownership transfer.'+@MSG
		RAISERROR (@MSG,16,1)
	END CATCH

END



GO
/****** Object:  Table [dbo].[__MigrationHistory]    Script Date: 1/18/2017 9:37:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[__MigrationHistory](
	[MigrationId] [nvarchar](150) NOT NULL,
	[ContextKey] [nvarchar](300) NOT NULL,
	[Model] [varbinary](max) NOT NULL,
	[ProductVersion] [nvarchar](32) NOT NULL,
 CONSTRAINT [PK_dbo.__MigrationHistory] PRIMARY KEY CLUSTERED 
(
	[MigrationId] ASC,
	[ContextKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Breed]    Script Date: 1/18/2017 9:37:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Breed](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](40) NOT NULL,
 CONSTRAINT [PK_Breed] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Breeds]    Script Date: 1/18/2017 9:37:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Breeds](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_dbo.Breeds] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Country]    Script Date: 1/18/2017 9:37:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Country](
	[Id] [int] NOT NULL,
	[Name] [nvarchar](100) NULL,
	[IsoCode] [char](3) NULL,
 CONSTRAINT [PK_Country] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Pet]    Script Date: 1/18/2017 9:37:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Pet](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[PetOwnerId] [int] NOT NULL,
	[Name] [nvarchar](40) NOT NULL,
	[DateOfBirth] [date] NOT NULL,
	[BreedId] [int] NOT NULL,
 CONSTRAINT [PK_Pet] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[PetOwner]    Script Date: 1/18/2017 9:37:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PetOwner](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](200) NOT NULL,
	[PolicyNumber] [varchar](40) NOT NULL,
	[PolicyDate] [datetime] NOT NULL,
	[CountryId] [int] NOT NULL,
	[StreetAddress1] [nvarchar](100) NOT NULL,
	[StreetAddress2] [nvarchar](100) NULL,
	[City] [nvarchar](50) NOT NULL,
	[State] [nchar](2) NOT NULL,
	[Zip] [nchar](10) NOT NULL,
 CONSTRAINT [PK_PetOwner] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PolicyNumbers]    Script Date: 1/18/2017 9:37:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PolicyNumbers](
	[Id] [int] IDENTITY(0,1) NOT NULL,
	[PolicyNumber] [char](13) NULL,
	[PetOwnerId] [int] NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Index [IX_Pet]    Script Date: 1/18/2017 9:37:24 PM ******/
CREATE NONCLUSTERED INDEX [IX_Pet] ON [dbo].[Pet]
(
	[DateOfBirth] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_PetOwner]    Script Date: 1/18/2017 9:37:24 PM ******/
CREATE NONCLUSTERED INDEX [IX_PetOwner] ON [dbo].[PetOwner]
(
	[PolicyDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Pet]  WITH CHECK ADD  CONSTRAINT [FK_Pet_Breed] FOREIGN KEY([BreedId])
REFERENCES [dbo].[Breed] ([Id])
GO
ALTER TABLE [dbo].[Pet] CHECK CONSTRAINT [FK_Pet_Breed]
GO
ALTER TABLE [dbo].[Pet]  WITH CHECK ADD  CONSTRAINT [FK_Pet_PetOwner] FOREIGN KEY([PetOwnerId])
REFERENCES [dbo].[PetOwner] ([Id])
GO
ALTER TABLE [dbo].[Pet] CHECK CONSTRAINT [FK_Pet_PetOwner]
GO
ALTER TABLE [dbo].[PetOwner]  WITH NOCHECK ADD  CONSTRAINT [FK_PetOwner_Country] FOREIGN KEY([CountryId])
REFERENCES [dbo].[Country] ([Id])
GO
ALTER TABLE [dbo].[PetOwner] CHECK CONSTRAINT [FK_PetOwner_Country]
GO

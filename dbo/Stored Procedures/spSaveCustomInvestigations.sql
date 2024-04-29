CREATE PROCEDURE [dbo].[spSaveCustomInvestigations]  
    @TestName varchar(200)

AS
	/*
	exec [dbo].[spSaveCustomInvestigations]  @TestName='Test56'
	
	select * from [Lookup].[Investigations] order by 1 desc
 Date					Author				Description          
 -----------------------------------------------------------------------------
07/09/2023			RAMYA GUDURI           Save Custom Investigations
 ------------------------------------------------------------------------------      
                Copyright 2023@YodaLIMS
*/ 
BEGIN
SET NOCOUNT ON
SET @TestName = IIF(@TestName='',null,@TestName)
Declare @InvestigationId int
Declare @InvestigationGuid uniqueidentifier
Select @InvestigationGuid=guid, @InvestigationId=id from [Lookup].[Investigations] with(nolock,readuncommitted) WHERE  Trim(Lower(TestName))=Trim(Lower(@TestName)) and IsDeleted=0
print @InvestigationGuid

if(@InvestigationGuid is null or @InvestigationGuid='00000000-0000-0000-0000-000000000000')
BEGIN
INSERT INTO [Lookup].[Investigations]
	(

	TestName,
	CreatedDt

	)
	VALUES (
	@TestName,
	GetDate()
	)
	SET @InvestigationId = scope_Identity()
		Select @InvestigationGuid=guid from [Lookup].[Investigations] with(nolock,readuncommitted) WHERE id=@InvestigationId
Select
	@InvestigationId as InvestigationId,
	@InvestigationGuid as InvestigationGuid ,
	'Investigation Name added successfully ' as Message

	from [Lookup].[Investigations]
	where id=@InvestigationId 
 END 
	
ELSE
	BEGIN
     Select 
	@InvestigationId as InvestigationId,
	@InvestigationGuid as InvestigationGuid ,
	'Investigation Name already exists ' as Message
	
	End


 SET NOCOUNT OFF 
END
GO


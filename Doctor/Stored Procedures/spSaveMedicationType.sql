CREATE PROCEDURE [Doctor].[spSaveMedicationType]     

		@MedicationType varchar(100)	
	
	
AS        
/*
 exec  [Doctor].[spSaveMedicationType]     ' AI 7'
 -------------------------------------------------------------              
    SELECT top 10 *FROM [Lookup].[Medications] order by 1 desc

 MODIFICATIONS        
 Date					Author				Description          
 ---------------------------------------------------------------------------------------

27/12/2022				Nikhita			Save QualificationTypes
 ---------------------------------------------------------------------------------------      
                Copyright 2022@Hireme
*/
BEGIN
SET NOCOUNT ON 
SET @MedicationType = IIF(@MedicationType='',null,@MedicationType)	 
Declare @MedicationId int
Declare @MedicationGuid uniqueidentifier
Select @MedicationGuid=guid, @MedicationId=Id from [Lookup].[Medications] with(nolock,readuncommitted) WHERE  Trim(Lower(MedicationName))=Trim(Lower(@MedicationType)) and IsDeleted=0

print @MedicationGuid
	if(@MedicationGuid is null or @MedicationGuid='00000000-0000-0000-0000-000000000000')
 BEGIN
	INSERT INTO [Lookup].[Medications]
	(

	MedicationName,
	CreatedDt

	)	
	VALUES (
	@MedicationType,
	GetDate()
	)
	SET @MedicationId = scope_Identity()
	Select @MedicationGuid=guid from [Lookup].[Medications] with(nolock,readuncommitted) WHERE id=@MedicationId

	Select
	@MedicationId as MedicationId,
	@MedicationGuid as MedicationGuid ,
	@MedicationType as MedicationName,
	'Medication type added successfully ' as Message

	from [Lookup].[Medications]
	where id=@MedicationId 
 END 
	
ELSE
	BEGIN
     Select 
	 @MedicationId as MedicationId,
	 @MedicationGuid as MedicationGuid,
	 @MedicationType as MedicationName,
       'Medication type  already exists' as Message
	
	
	End


 SET NOCOUNT OFF 
END
GO


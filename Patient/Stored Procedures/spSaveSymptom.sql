CREATE PROCEDURE [Patient].[spSaveSymptom]      

		@SymptomType varchar(100)	
	
	
AS        
/*
 exec  [Patient].[spSaveSymptom]     ' AfKNV'
 -------------------------------------------------------------              
    SELECT top 10 *FROM [Lookup].[Symptom] order by 1 desc

 MODIFICATIONS        
 Date					Author				Description          
 ---------------------------------------------------------------------------------------

7/9/2023				Nikhita			Save Symptom
 ---------------------------------------------------------------------------------------      
                Copyright 2022@Hireme
*/
BEGIN
SET NOCOUNT ON 
SET @SymptomType = IIF(@SymptomType='',null,@SymptomType)	 
Declare @SymptomId int
Declare @SymptomGuid uniqueidentifier
Select @SymptomGuid=guid, @SymptomId=Id from [Lookup].[Symptom] with(nolock,readuncommitted) WHERE  Trim(Lower(SymptomName))=Trim(Lower(@SymptomType)) and IsDeleted=0

print @SymptomGuid
	if(@SymptomGuid is null or @SymptomGuid='00000000-0000-0000-0000-000000000000')
 BEGIN
	INSERT INTO  [Lookup].[Symptom]
	(

	SymptomName,
	CreatedDt

	)	
	VALUES (
	@SymptomType,
	GetDate()
	)
	SET @SymptomId = scope_Identity()
	Select @SymptomGuid=guid from [Lookup].[Symptom] with(nolock,readuncommitted) WHERE id=@SymptomId

	Select
	@SymptomId as SymptomId,
	@SymptomGuid as SymptomGuid ,
	'Symptom added successfully ' as Message

	from [Lookup].[Symptom]
	where id=@SymptomId 
 END 
	
ELSE
	BEGIN
     Select 
	 @SymptomId as SymptomId,
	 @SymptomGuid as SymptomGuid,
       'Symptom already exists' as Message
	
	
	End


 SET NOCOUNT OFF 
END
GO


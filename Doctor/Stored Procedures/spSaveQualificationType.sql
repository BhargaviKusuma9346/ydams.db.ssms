
Create PROCEDURE [Doctor].[spSaveQualificationType]     

		@QualificationType varchar(100)	
	
	
AS        
/*
 exec  [Doctor].[spSaveQualificationType]    ' AI 7'
 -------------------------------------------------------------              
    SELECT top 10 *FROM [Lookup].[DrQualification] order by 1 desc

 MODIFICATIONS        
 Date					Author				Description          
 ---------------------------------------------------------------------------------------

27/12/2022				Nikhita			Save QualificationTypes
 ---------------------------------------------------------------------------------------      
                Copyright 2022@Hireme
*/
BEGIN
SET NOCOUNT ON 
SET @QualificationType = IIF(@QualificationType='',null,@QualificationType)	 
Declare @QualificationId int
Declare @QualificationGuid uniqueidentifier
Select @QualificationGuid=guid, @QualificationId=Id from [Lookup].[DrQualification] with(nolock,readuncommitted) WHERE  Trim(Lower(QualificationName))=Trim(Lower(@QualificationType)) and IsDeleted=0

print @QualificationGuid
	if(@QualificationGuid is null or @QualificationGuid='00000000-0000-0000-0000-000000000000')
 BEGIN
	INSERT INTO [Lookup].[DrQualification]
	(

	QualificationName,
	CreatedDt

	)	
	VALUES (
	@QualificationType,
	GetDate()
	)
	SET @QualificationId = scope_Identity()
	Select @QualificationGuid=guid from [Lookup].[DrQualification] with(nolock,readuncommitted) WHERE id=@QualificationId

	Select
	@QualificationId as QualificationId,
	@QualificationGuid as QualificationGuid ,
	'Qualification type added successfully ' as Message

	from [Lookup].[DrQualification]
	where id=@QualificationId 
 END 
	
ELSE
	BEGIN
     Select 
	 @QualificationId as QualificationId,
	 @QualificationGuid as QualificationGuid,
       'Qualification type  already exists' as Message
	
	
	End


 SET NOCOUNT OFF 
END

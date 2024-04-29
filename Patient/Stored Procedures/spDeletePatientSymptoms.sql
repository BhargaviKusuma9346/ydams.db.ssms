
CREATE procedure [Patient].[spDeletePatientSymptoms] 
   @AppointmentGuid  uniqueidentifier
  ,@SymptomGuid uniqueidentifier

AS        
      
/*
 exec [Patient].[spDeletePatientSymptoms]    
      @AppointmentGuid = '03ddb3dd-7db4-4ca7-ad54-b27ac186a1b7',
      @SymptomGuid = 'd4eba4ce-9387-496d-b26a-c6dd7d6de2a9'
 -------------------------------------------------------------              
	select * from mapping.PatientSymptoms where IsDeleted=1

 MODIFICATIONS        
 Date					Author				Description          
 -----------------------------------------------------------------------------
20/04/2023			   M.Chandrani	           to delete Symptoms Details
 ------------------------------------------------------------------------------      
                Copyright 2023@YLIMS
*/        
BEGIN 

SET NOCOUNT ON

/*Declaration */
DECLARE @AppointmentId INT,@PatientId INT 
SELECT @AppointmentId=id,@PatientId=PatientId from [Patient].[Appointment] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and guid=@AppointmentGuid

DECLARE @SymptomName varchar(100)
SELECT @SymptomName=SymptomName from [Lookup].[Symptom] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and Guid=@SymptomGuid


DECLARE @Id INT 
SELECT @Id=id from [mapping].[PatientSymptoms] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and (PatientId =@PatientId and AppointmentId=@AppointmentId) and (Symptoms=@SymptomName)

/*Main Query */
UPDATE
	mapping.PatientSymptoms
SET
	IsDeleted=1
WHERE
	 Id = @Id

SET NOCOUNT OFF

END

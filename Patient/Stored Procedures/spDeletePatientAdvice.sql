
CREATE procedure [Patient].[spDeletePatientAdvice] 
   @AppointmentGuid  uniqueidentifier

AS        
      
/*
 exec [Patient].[spDeletePatientAdvice]   
      @AppointmentGuid = '03ddb3dd-7db4-4ca7-ad54-b27ac186a1b7'
 -------------------------------------------------------------              
	select * from mapping.PatientAdvice where IsDeleted=1

 MODIFICATIONS        
 Date					Author				Description          
 -----------------------------------------------------------------------------
20/04/2023			   M.Chandrani	           to delete Advice Details
 ------------------------------------------------------------------------------      
                Copyright 2023@YLIMS
*/        
BEGIN 

SET NOCOUNT ON

/*Declaration */
DECLARE @AppointmentId INT,@PatientId INT 
SELECT @AppointmentId=id,@PatientId=PatientId from [Patient].[Appointment] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and guid=@AppointmentGuid

DECLARE @Id INT 
SELECT @Id=id from [mapping].[PatientAdvice] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and AppointmentId=@AppointmentId

/*Main Query */
UPDATE
	[mapping].[PatientAdvice]
SET
	IsDeleted=1
WHERE
	 Id = @Id

SET NOCOUNT OFF

END

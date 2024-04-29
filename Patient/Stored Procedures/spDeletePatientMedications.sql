CREATE procedure [Patient].[spDeletePatientMedications] 
   @AppointmentGuid  uniqueidentifier
  ,@MedicationName varchar(200)

AS        
      
/*
 exec [Patient].[spDeletePatientMedications]    
      @AppointmentGuid = '0c7a939f-68ef-42cf-8520-48be95170e5a',
      @MedicationName  ='Paracetamol2'
 -------------------------------------------------------------              
	select * from mapping.PatientMedications where IsDeleted=1

 MODIFICATIONS        
 Date					Author				Description          
 -----------------------------------------------------------------------------
20/04/2023			   M.Chandrani	           to delete Patients Details
 ------------------------------------------------------------------------------      
                Copyright 2023@YLIMS
*/        
BEGIN 

SET NOCOUNT ON

/*Declaration */
DECLARE @AppointmentId INT 
SELECT @AppointmentId=id from [Patient].[Appointment] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and guid=@AppointmentGuid
DECLARE @Id INT 
SELECT @Id=id from [mapping].[PatientMedications] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and (AppointmentId=@AppointmentId and MedicationName=@MedicationName)
/*Main Query */
UPDATE
	mapping.PatientMedications
SET
	IsDeleted=1
WHERE
	 Id = @Id

SET NOCOUNT OFF

END
GO


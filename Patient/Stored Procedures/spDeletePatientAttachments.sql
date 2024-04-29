
CREATE procedure [Patient].[spDeletePatientAttachments] 
   @AppointmentGuid  uniqueidentifier
  ,@AttachmentGuid uniqueidentifier

AS        
      
/*
 exec [Patient].[spDeletePatientAttachments]    
      @AppointmentGuid = '4B59F148-6726-440D-84B3-B593B41AC972',
      @AttachmentGuid = '3CA13EA1-012A-43C9-8849-045A10A664E8'
 -------------------------------------------------------------              
	select * from mapping.PatientAttachments where IsDeleted=1

 MODIFICATIONS        
 Date					Author				Description          
 -----------------------------------------------------------------------------
20/04/2023			   M.Chandrani	           to delete PatientAttachments Details
 ------------------------------------------------------------------------------      
                Copyright 2023@YLIMS
*/        
BEGIN 

SET NOCOUNT ON

/*Declaration */

DECLARE @AppointmentId INT,@PatientId INT 
SELECT @AppointmentId=id,@PatientId=PatientId from [Patient].[Appointment] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and guid=@AppointmentGuid

DECLARE @Id INT 
SELECT @Id=id from [mapping].[PatientAttachments] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and Guid=@AttachmentGuid

/*Main Query */
UPDATE
	mapping.PatientAttachments
SET
	IsDeleted=1
WHERE
	 Id = @Id

SET NOCOUNT OFF

END

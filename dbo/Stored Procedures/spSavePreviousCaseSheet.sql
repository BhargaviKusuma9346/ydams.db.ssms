
CREATE PROCEDURE [dbo].[spSavePreviousCaseSheet] 
	   @AppointmentId  Int
	  ,@PreviousAppointmentId Int
 AS
 
/*
exec [dbo].[spSavePreviousCaseSheet] 
      @AppointmentId=@AppointmentId,@PreviousAppointmentId=@PreviousAppointmentId


 Date					Author				Description          
 -----------------------------------------------------------------------------
27/04/2023			M Chandrani	           Save Patient Previous case sheet related information
 ------------------------------------------------------------------------------      
                Copyright 2023@YodaLIMS
*/ 

BEGIN
SET NOCOUNT ON

/*Main Query */

/**Symptoms**/
insert into [mapping].[PatientSymptoms](AppointmentId, PatientId, Symptoms, SeverityLevel, Description)
select 
   @PreviousAppointmentId,
   PatientId,
   Symptoms,
   SeverityLevel,
   Description
from 
   [mapping].[PatientSymptoms]
   where 
   AppointmentId=@AppointmentId
    and 
   IsDeleted=0

/**Vitals**/    
insert into [mapping].[PatientVitals](AppointmentId, PatientId, VitalId, VitalName, VitalValue)
select 
   @PreviousAppointmentId,
   PatientId,
   VitalId,
   VitalName,
   VitalValue
from 
   [mapping].[PatientVitals]
   where 
   AppointmentId=@AppointmentId
    and 
   IsDeleted=0
   
/** Physical Examinations **/
insert into [mapping].[PatientPhysicalExaminations](AppointmentId, PatientId, PhysicalExaminationName)
select 
   @PreviousAppointmentId,
   PatientId,
   PhysicalExaminationName
from 
   [mapping].[PatientPhysicalExaminations]
   where 
   AppointmentId=@AppointmentId
    and 
   IsDeleted=0

/** Attachements **/
insert into [mapping].[PatientAttachments](AppointmentId, PatientId, AttachmentTitle,AttachmentUrl)
select 
   @PreviousAppointmentId,
   PatientId,
   AttachmentTitle,
   AttachmentUrl
from 
   [mapping].[PatientAttachments]
   where 
   AppointmentId=@AppointmentId
    and 
   IsDeleted=0

/** Past History Questions **/
insert into [mapping].[PatientPastHistory](AppointmentId, PatientId, QuestionId,Answer)
select 
   @PreviousAppointmentId,
   PatientId,
   QuestionId,
   Answer
from 
   [mapping].[PatientPastHistory]
   where 
   AppointmentId=@AppointmentId
    and 
   IsDeleted=0

SET NOCOUNT OFF
END




  




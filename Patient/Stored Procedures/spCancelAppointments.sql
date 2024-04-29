
CREATE procedure [Patient].[spCancelAppointments]
  @AppointmentGuid uniqueIdentifier  
AS        
      
/*
 exec [Patient].[spCancelAppointments] @AppointmentGuid='3DF3D1AF-6352-49A2-90E6-C112F78C8452'
 -------------------------------------------------------------              
    select * from  [Patient].[Appointment] where IsDeleted=1	
	
 MODIFICATIONS        
 Date					Author				Description          
 -----------------------------------------------------------------------------
20/04/2023			 Nikhita	           Cancel appointment
 ------------------------------------------------------------------------------      
                Copyright 2023@YLIMS
*/ 

BEGIN 

SET NOCOUNT ON

	UPDATE
	     [Patient].[Appointment]	    
    SET
	     IsDeleted=1
	WHERE
	     Guid=@AppointmentGuid
	

SET NOCOUNT OFF

END
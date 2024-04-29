CREATE PROCEDURE [Patient].[spUpdateSheduleAppointment] 
     @AppointmentGuid  uniqueidentifier=null    
	,@IsPatientAttended bit =null
	,@IsDoctorAttended bit=null
	,@IsCoordinatorAttended bit=null
 AS
 
/*
select * from [Patient].[Appointment] order by 1 desc 
select * from [Patient].[Patient]
select * from [Doctor].[Doctor]
select * from [Coordinator].[Coordinator]
select * from mapping.patientvitals order by 1 desc

 
exec  [Patient].[spUpdateJoinCall] 
       @AppointmentGuid='BFA33388-1E3D-4C5E-ABBC-553FFE1180A8'      
	  ,@IsPatientAttended=0
	  ,@IsDoctorAttended=0
	  ,@IsCoordinatorAttended=1
	  

 Date					Author				Description          
 -------------------------------------- ---------------------------------------
03/05/2023			ch.karthik	           Save Patient Appointment information
 ------------------------------------------------------------------------------      
                Copyright 2023@YodaLIMS
*/ 

BEGIN
SET NOCOUNT ON
/*Declaration */

	if(@IsPatientAttended=1)
	begin 
		UPDATE [Patient].[Appointment]  SET	IsPatientAttended=1  WHERE Guid=@AppointmentGuid 
	end

	 if(@IsCoordinatorAttended=1)
	begin 
		UPDATE [Patient].[Appointment]  SET	IsCoordinatorAttended=1  WHERE Guid=@AppointmentGuid 
	end


	 if(@IsDoctorAttended=1)
	begin 
		UPDATE [Patient].[Appointment]  SET	IsDoctorAttended=1  WHERE Guid=@AppointmentGuid 
	end


SET NOCOUNT OFF
END
GO


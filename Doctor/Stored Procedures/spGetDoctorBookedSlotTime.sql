CREATE procedure [Doctor].[spGetDoctorBookedSlotTime]
  @PatientGuid uniqueidentifier=null,
  @DoctorGuid uniqueidentifier=null,
  @AppointmentDate datetime=null

AS        

/*
 exec [Doctor].[spGetDoctorBookedSlotTime] @PatientGuid='7998AD13-73A1-4A6B-9AE9-CB8FAC3315AF', @DoctorGuid='057FB387-6989-4E2D-B9AE-B73175E111BB',@AppointmentDate='2023-09-08 21:10:00.000'
-------------------------------------------------------------      

select * from [Patient].[Appointment] order by 1 desc
select * from  [Doctor].[Doctor] where id=14154
select * from [Patient].[Patient] where id=20672
MODIFICATIONS        
   Date                    Author                Description          
-----------------------------------------------------------------------------
20/08/2023              Ch.Karthik    to get specific doctor availability timings
------------------------------------------------------------------------------      
                Copyright 2023@YLIMS
*/        
BEGIN
DECLARE @PatientId INT
DECLARE @DoctorId INT

SELECT @PatientId = Id FROM [Patient].[Patient] WHERE Guid = @PatientGuid
SELECT @DoctorId = Id FROM [Doctor].[Doctor] WHERE Guid = @DoctorGuid

SET NOCOUNT ON

SELECT AppointmentDate
FROM [Patient].[Appointment]
WHERE 
    (@PatientId = PatientId OR @DoctorId = DoctorId)  -- Either PatientId or DoctorId should match
    AND AppointmentDate = @AppointmentDate            -- AppointmentDate should match
    AND IsDeleted = 0                                 -- IsDeleted should be 0
    AND IsConfirmed = 1                              -- IsConfirmed should be 1


SET NOCOUNT OFF
END
GO


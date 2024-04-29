
CREATE PROCEDURE [Doctor].[spSaveDoctorAvailability]
     @UserGuid uniqueidentifier = null
    ,@AppointmentDuration int
    ,@IsSunday bit=0
	,@IsMonday bit=0
	,@IsTuesday bit=0
	,@IsWednesday bit=0
	,@IsThursday bit=0
	,@IsFriday bit=0
	,@IsSaturday bit=0	
	,@DoctorAvailabilitySlotsUDT [Doctor].[DoctorAvailabilitySlotsUDT] readonly

 AS

/*

 MODIFICATIONS

 select * from [Doctor].[Doctor] where GUID='24266F46-F885-4E27-8632-CD1BC4BACDB5'

 select * from doctor.availability order by 1 desc

 DECLARE @DoctorAvailabilitySlotsUDT [Doctor].[DoctorAvailabilitySlotsUDT]

 insert into @DoctorAvailabilitySlotsUDT values
 (null,2,'Mondayslot','00:00:00','00:30:00',0,0),
 (null,3,'Tuesdayslot','00:00:00','00:30:00',0,0),
 (null,4,'Wednesdayslot','00:00:00','00:30:00',0,0),
 (null,5,'Thursdayslot','00:00:00','00:30:00',0,0),
 (null,6,'Fridayslot','00:00:00','00:30:00',0,0),
 (null,7,'Saturdayslot','00:00:00','00:30:00',0,0),
  (null,1,'Sundayslot','00:00:00','00:30:00',0,0)
 
 exec [Doctor].[spSaveDoctorAvailability]
             @UserGuid='5ea3279c-22c1-4340-a05c-9110205ae400'
            ,@AppointmentDuration=30
			,@IsSunday=1
            ,@IsMonday=1
            ,@IsTuesday=1
            ,@IsWednesday=1
            ,@IsThursday=1
            ,@IsFriday=1
            ,@IsSaturday=1
			,@DoctorAvailabilitySlotsUDT=@DoctorAvailabilitySlotsUDT
			
 Date					Author				Description          
 -----------------------------------------------------------------------------
 07/04/2023			M Chandrani           Addition of Doctors Availability
 ------------------------------------------------------------------------------      
                Copyright 2023@YodaLIMS
*/ 

BEGIN
SET NOCOUNT ON
/*Declaration */

DECLARE @UserId INT
SELECT @UserId=UserId from [dbo].[Users] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and UserGuid=@UserGuid

DECLARE @DoctorId INT 
SELECT @DoctorId=Id from [Doctor].[Doctor] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and UserId=@UserId

/*Main Query */
IF EXISTS (SELECT Id from [Doctor].[Doctor] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and UserId=@UserId)
BEGIN

     UPDATE [Doctor].[Doctor]
	   SET
	        [AppointmentDurationInMin]=@AppointmentDuration       
           ,[IsSunday]=@IsSunday
           ,[IsMonday]=@IsMonday
           ,[IsTuesday]=@IsTuesday
           ,[IsWednesday]=@IsWednesday
           ,[IsThursday]=@IsThursday
           ,[IsFriday]=@IsFriday
           ,[IsSaturday]=@IsSaturday
		WHERE
		   UserId=@UserId

	  MERGE [Doctor].[Availability] AS Target 
		 USING @DoctorAvailabilitySlotsUDT	AS Source 
		 ON  Source.DoctorAvailabilitySlotGuid=Target.Guid
	   WHEN MATCHED THEN 
	   UPDATE 
	    SET
		  target.StartTime=Source.StartTime,
		  target.EndTime=Source.EndTime,
		  target.NumberOfSlots= DATEDIFF(MINUTE, Source.StartTime, Source.EndTime)/@AppointmentDuration,
		  target.IsDeleted=Source.IsDeleted
		  -- For Inserts
	   WHEN NOT MATCHED BY Target 
	    THEN
	      INSERT (DoctorId,WeekDayId, SlotName,StartTime,EndTime,NumberOfSlots,IsDeleted) 
	         VALUES (@DoctorId,Source.WeekDayId, Source.SlotName,Source.StartTime,Source.EndTime,DATEDIFF(MINUTE,Source.StartTime,Source.EndTime)/@AppointmentDuration,Source.IsDeleted);
END

SET NOCOUNT OFF
END




  




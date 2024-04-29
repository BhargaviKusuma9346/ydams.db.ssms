
CREATE procedure [Doctor].[spGetTimeSlotDetails]
  @UserGuid uniqueIdentifier
  
AS        
      
/*
 exec [Doctor].[spGetTimeSlotDetails]   @UserGuid='5ea3279c-22c1-4340-a05c-9110205ae400'

 -------------------------------------------------------------              

 MODIFICATIONS        
 Date					Author				Description          
 -----------------------------------------------------------------------------
20/04/2023			   M.Chandrani	           to get specific doctor timing slots information
 ------------------------------------------------------------------------------      
                Copyright 2023@YLIMS
*/        
BEGIN 

SET NOCOUNT ON

DECLARE @UserId INT
SELECT @UserId=UserId from [dbo].[Users] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and UserGuid=@UserGuid

DECLARE @DoctorId INT 
SELECT @DoctorId=Id from [Doctor].[Doctor] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and UserId=@UserId

SELECT
   dd.Guid as DoctorGuid,
   dd.Id as DoctorId,
   dd.AppointmentDurationInMin,
   CASE WHEN dd.IsSunday = 1 THEN 'true' ELSE 'false' END AS IsSunday ,
   CASE WHEN dd.IsMonday = 1 THEN 'true' ELSE 'false' END AS IsMonday ,
   CASE WHEN dd.IsTuesday = 1 THEN 'true' ELSE 'false' END AS IsTuesday ,
   CASE WHEN dd.IsWednesday = 1 THEN 'true' ELSE 'false' END AS IsWednesday ,
   CASE WHEN dd.IsThursday = 1 THEN 'true' ELSE 'false' END AS IsThursday ,
   CASE WHEN dd.IsFriday = 1 THEN 'true' ELSE 'false' END AS IsFriday  ,
   CASE WHEN dd.IsSaturday = 1 THEN 'true' ELSE 'false' END AS IsSaturday,
   da.Guid as SlotGuid,
   da.WeekDayId, 
   da.SlotName,
   da.StartTime,
   da.EndTime,
   da.NumberOfSlots,
   da.IsDeleted
FROM
   [Doctor].[Doctor] dd WITH(NOLOCK,READUNCOMMITTED)
left JOIN
   [Doctor].[Availability] da WITH(NOLOCK,READUNCOMMITTED)
ON
   dd.Id=da.DoctorId
WHERE
   dd.Id=@DoctorId
   AND 
   da.IsDeleted=0
   AND
   dd.IsDeleted=0
   
SET NOCOUNT OFF
END

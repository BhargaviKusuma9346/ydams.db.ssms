
CREATE procedure [Doctor].[spGetBookedSlots]
  @Date DATETIME,
  @DoctorGuid uniqueidentifier=null

AS        

/*
exec [Doctor].[spGetBookedSlots] @Date='2023-08-22'
-------------------------------------------------------------              

MODIFICATIONS        
Date                    Author                Description          
-----------------------------------------------------------------------------
17/08/2023               M.Chandrani               to get booked slots info
------------------------------------------------------------------------------      
                Copyright 2023@YLIMS
*/        
BEGIN

SET NOCOUNT ON

SELECT 
    dd.Guid as DoctorGuid,
	dd.FirstName,
	pa.AppointmentDate,
	Concat(CAST(pa.AppointmentDate AS DATE),' ',pa.SlotStartTime) as StartTime,
	Concat(CAST(pa.AppointmentDate AS DATE),' ',pa.SlotEndTime) as EndTime
FROM 
    patient.appointment pa WITH(NOLOCK,READUNCOMMITTED)
INNER JOIN
    doctor.doctor dd WITH(NOLOCK,READUNCOMMITTED)
	on dd.Id=pa.DoctorId
WHERE
    CAST(AppointmentDate AS DATE) = CAST(@Date AS DATE)
	AND
	pa.IsConfirmed=1
	AND
	pa.IsDeleted=0
order by dd.guid 

SET NOCOUNT OFF
END
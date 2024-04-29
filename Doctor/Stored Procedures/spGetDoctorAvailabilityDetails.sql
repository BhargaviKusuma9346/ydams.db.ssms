CREATE procedure [Doctor].[spGetDoctorAvailabilityDetails]
  @Date DATETIME,
  @Keyword varchar(max)=''

AS        

/*
 exec [Doctor].[spGetDoctorAvailabilityDetails] @Date='2023-08-08',@Keyword='Dermatology'
-------------------------------------------------------------              
MODIFICATIONS        
   Date                    Author                Description          
-----------------------------------------------------------------------------
20/08/2023               M.Chandrani       to get specific doctor availability timings
------------------------------------------------------------------------------      
                Copyright 2023@YLIMS
*/        
BEGIN

SET NOCOUNT ON

DECLARE @WeekDayId INT

-- Retrieve WeekDayId based on the specified date
SELECT @WeekDayId = DATEPART(WEEKDAY, @Date)

SELECT 
    dd.Guid as DoctorGuid,
    dd.Gender as DoctorGender,
    dd.DateOfBirth as DoctorDateOfBirth,
    dd.ProfileURL as DoctorProfileUrl,
    dd.SpecializationName,
    dd.FirstName as DoctorFirstName,
    dd.LastName as DoctorLastName,
    dd.PracticeStartDate,
    dd.Languages,
	dd.ContactNumber as DoctorPhone,
    dd.ConsultationFee,
	dd.AppointmentDurationInMin as AppointmentDuration,
    da.StartTime,
    da.EndTime,
	dd.QualificationName
FROM 
    doctor.Availability da
INNER JOIN
    doctor.doctor dd ON dd.Id = da.DoctorId
INNER JOIN
    dbo.Users du ON dd.UserId = du.UserId
WHERE
    da.WeekDayId = @WeekDayId
    AND da.IsDeleted = 0
    AND du.IsDeleted = 0
    AND dd.IsDeleted = 0
    AND dd.IsAvailable = 1
    AND (dd.FirstName LIKE '%' + @Keyword + '%' 
         OR dd.LastName LIKE '%' + @Keyword + '%' 
         OR CONCAT(TRIM(dd.FirstName), ' ', TRIM(dd.LastName)) LIKE '%' + @Keyword + '%' 
         OR dd.SpecializationName LIKE '%' + @Keyword + '%'  OR dd.QualificationName LIKE '%' + @Keyword + '%' 
         OR dd.Languages LIKE '%' + @Keyword + '%')

SET NOCOUNT OFF
END
GO


CREATE procedure [Doctor].[spGetSpecificDoctorDetails]
  @DoctorGuid uniqueIdentifier
  
AS        
      
/*
 exec [Doctor].[spGetSpecificDoctorDetails]   @DoctorGuid='016D9615-FB7D-4FDE-AEAD-CA9C4052AFBA'
 select * from doctor.doctor where Guid='DBE9792C-D5A5-4294-9AF9-05F230E411A0'
 -------------------------------------------------------------              

 MODIFICATIONS        
 Date					Author				Description          
 -----------------------------------------------------------------------------
20/04/2023			   M.Chandrani	           to get specific doctor information
 ------------------------------------------------------------------------------      
                Copyright 2023@YLIMS
*/        
BEGIN 

SET NOCOUNT ON

SELECT 
     dd.Id as DoctorId,
	 dd.Guid as DoctorGuid,
	 dd.UserId,
	 du.UserName,
	 du.PasswordHash,
	 dd.FirstName,
	 dd.LastName,
	 dd.Gender,
     CONVERT(varchar, dd.DateOfBirth, 105) as DateOfBirth,
	 dd.ProfileURL,
	 dd.SignUrl,
	 dd.QualificationName,
	 dd.SpecializationName,
	 dd.Languages,
	 dd.ContactNumber,
	 dd.EmailId,
	 lc.Guid as CityGuid,
	 dd.City,
	 ls.Guid as StateGuid,
	 dd.State,
	 dd.Pincode,
	 dd.Address,
	 dd.RegistrationNumber,
	 lsr.Guid as StateOfRegistrationGuid,
	 dd.StateOfRegistration,
	 dd.YearOfRegistration,
	 CONVERT(varchar, dd.RegistrationDate, 105) as RegistrationDate,
	 CONVERT(varchar, dd.RegistrationValidity, 105) as RegistrationValidity,
	 dd.AlternateNumber,
	 CONVERT(varchar, dd.PracticeStartDate, 105) as PracticeStartDate,
	 dd.ConsultationFee,
	 dd.CreatedDt 
 FROM 
	[Doctor].[Doctor] dd WITH(NOLOCK,READUNCOMMITTED)
	LEFT JOIN
	[Lookup].[City] lc WITH(NOLOCK,READUNCOMMITTED)
	ON dd.City = lc.CityName AND lc.IsDeleted=0
	LEFT JOIN
	[Lookup].[State] ls WITH(NOLOCK,READUNCOMMITTED)
	ON dd.State = ls.StateName AND ls.IsDeleted=0
	LEFT JOIN
	[Lookup].[State] lsr WITH(NOLOCK,READUNCOMMITTED)
	ON dd.StateOfRegistration=lsr.StateName
	LEFT JOIN
	[dbo].[Users] du WITH(NOLOCK,READUNCOMMITTED)
	ON du.UserId=dd.UserId
 WHERE 
	dd.IsDeleted=0
	AND
	du.IsDeleted=0
	AND
	dd.Guid=@DoctorGuid

SELECT 
    dd.Guid AS DoctorGuid,
    dd.FirstName,
    dd.LastName,
    ll.Guid AS LanguageGuid,
    ll.Languages AS Language
FROM
    [Doctor].[Doctor] dd WITH(NOLOCK,READUNCOMMITTED)
    CROSS APPLY STRING_SPLIT(dd.Languages, ',') AS l
    INNER JOIN [Lookup].[Languages] ll WITH(NOLOCK,READUNCOMMITTED)
        ON l.value = ll.Languages
WHERE
   dd.IsDeleted=0
   AND
   ll.IsDeleted=0
   AND
   dd.Guid=@DoctorGuid

SELECT 
    dd.Guid AS DoctorGuid,
    dd.FirstName,
    dd.LastName,
    dq.Guid AS QualificationGuid,
    dq.QualificationName AS QualificationName
FROM
    [Doctor].[Doctor] dd WITH(NOLOCK,READUNCOMMITTED)
    CROSS APPLY STRING_SPLIT(dd.QualificationName, ',') AS qn
    INNER JOIN [Lookup].[DrQualification] dq WITH(NOLOCK,READUNCOMMITTED)
        ON qn.value = dq.QualificationName
WHERE
   dd.IsDeleted=0
   AND
   dq.IsDeleted=0
   AND
   dd.Guid=@DoctorGuid

SELECT 
    dd.Guid AS DoctorGuid,
    dd.FirstName,
    dd.LastName,
	ds.Guid as SpecializationGuid,
	ds.SpecializationName
FROM
    [Doctor].[Doctor] dd WITH(NOLOCK,READUNCOMMITTED)
    CROSS APPLY STRING_SPLIT(dd.SpecializationName, ',') AS sn
    INNER JOIN [Lookup].[DrSpecialization] ds WITH(NOLOCK,READUNCOMMITTED)
        ON sn.value = ds.SpecializationName
WHERE
   dd.IsDeleted=0
   AND
   ds.IsDeleted=0
   AND
   dd.Guid=@DoctorGuid

SELECT 
	 dd.Guid as DoctorGuid,
	 CONCAT(dd.[FirstName],' ',dd.[LastName]) as DoctorName,
	 pp.Guid as PatientGuid,
	 CONCAT(pp.[FirstName],' ',pp.[MiddleName],' ',pp.[LastName]) as PatientName,
	 cc.Guid as CoordinatorGuid,
	 CONCAT(cc.[FirstName],' ',cc.[LastName]) as CoordinatorName,
	 pa.Guid as AppointmentGuid,
	 pa.AppointmentDate,
	 pa.AppointmentName,
	 pa.Description,
	 pp.Gender as PatientGender,
	 CONVERT(varchar, pp.DateOfBirth, 105) as PatientDOB,
	 pp.MobileNumber as PatientMobileNumber,
	 CASE WHEN pa.IsPatientAttended = 1 THEN 'true' ELSE 'false' END AS IsPatientAttended ,
	 CASE WHEN pa.IsCoordinatorAttended = 1 THEN 'true' ELSE 'false' END AS IsCoordinatorAttended,
	 CASE WHEN pa.IsDoctorAttended = 1 THEN 'true' ELSE 'false' END AS IsDoctorAttended,
	 CASE WHEN pa.IsRescheduled = 1 THEN 'true' ELSE 'false' END AS IsRescheduled,
	 pa.VideoUrl,
	 pa.AppointmentDuration
FROM
    [Doctor].[Doctor] dd WITH(NOLOCK,READUNCOMMITTED)
	INNER JOIN
	[Patient].[Appointment] pa WITH(NOLOCK,READUNCOMMITTED)
	ON pa.DoctorId = dd.Id
	INNER JOIN
    [Patient].[Patient] pp WITH(NOLOCK,READUNCOMMITTED)
	on pp.Id= pa.PatientId 
	INNER JOIN
    [Coordinator].[Coordinator] cc WITH(NOLOCK,READUNCOMMITTED)
	on cc.Id= pa.CoordinatorId 
	INNER JOIN
	[dbo].[Users] du1 WITH(NOLOCK,READUNCOMMITTED)
	on dd.UserId=du1.UserId
	INNER JOIN
	[dbo].[Users] du2 WITH(NOLOCK,READUNCOMMITTED)
	on pp.UserId=du2.UserId
	INNER JOIN
	[dbo].[Users] du3 WITH(NOLOCK,READUNCOMMITTED)
	on cc.UserId=du3.UserId
 WHERE 
	pp.IsDeleted=0
	AND
	pa.IsConfirmed=1
	AND
	dd.IsDeleted=0
	AND
	du1.IsDeleted=0
	AND
	du2.IsDeleted=0
	AND
	du3.IsDeleted=0
	AND
	cc.IsDeleted=0
	AND
	dd.Guid=@DoctorGuid


SET NOCOUNT OFF

END
GO


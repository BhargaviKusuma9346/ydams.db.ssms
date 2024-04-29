CREATE procedure [Patient].[spGetSpecificPatientDetails]
  @PatientGuid uniqueIdentifier
  
AS        
      
/*
 exec [Patient].[spGetSpecificPatientDetails] @PatientGuid='65c5b7e5-8f9b-4b77-8d9b-2ad1f5b4ca94'
 select * from patient.patient where Guid='C66BDB88-1ECF-42C9-9A8D-53ECC3C031EB'
 -------------------------------------------------------------              

 MODIFICATIONS        
 Date					Author				Description          
 -----------------------------------------------------------------------------
20/04/2023			   M.Chandrani	           to get specific patient details
 ------------------------------------------------------------------------------      
                Copyright 2023@YLIMS
*/        
BEGIN 

SET NOCOUNT ON

SELECT 
	 pp.Guid as PatientGuid,
	 pp.Id as PatientId,
	 pp.UserId as PatientUserId,
	 du.UserGuid as PatientUserGuid,
	 pp.Title,
	 pp.FirstName,
	 pp.MiddleName,
	 pp.LastName,
	 pp.CountryCode,
	 pp.MobileNumber,
	 pp.AlternativeMobileNumber as AlternateMobileNumber,
	 pp.Email as EmailId,
	 pp.Gender,
	 CONVERT(varchar, pp.DateOfBirth, 105) as DateOfBirth,
	 apt.Guid as AddressProofTypeGuid,
     pp.AddressProofType,
     pp.IdentificationNumber,
     pp.MaritalStatus,
	 oo.Guid as OccupationGuid,
     pp.OccupationName,
	 rn.Guid as ReligionGuid,
     pp.ReligionName,
	 ign.Guid as IncomeGroupGuid,
     pp.IncomeGroupName,
	 en.Guid as EducationGuid,
     pp.EducationName,
     pp.BloodGroup,
	 rt.Guid as RelationshipTypeGuid,
     pp.RelationshipType,
     pp.RelationName,
     pp.MothersMaidenName,
	 lc.Guid as CityGuid,
     pp.CityName,
	 ls.Guid as StateGuid,
     pp.StateName,
     pp.Address1,
     pp.Address2,
     pp.PatientPhotoURL,
	 pp.CreatedByUserId,
	 (SELECT AppointmentDate FROM [Patient].[Appointment] WHERE PatientId = pp.Id and ((IsPatientAttended=1 or IsCoordinatorAttended=1) and IsDoctorAttended=1) ORDER BY AppointmentDate DESC OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY) AS LastConsultedDate
FROM 
	[Patient].[Patient] pp WITH(NOLOCK,READUNCOMMITTED)
    INNER JOIN
	[Lookup].[City] lc WITH(NOLOCK,READUNCOMMITTED)
	ON pp.CityName = lc.CityName
	INNER JOIN
	[Lookup].[State] ls WITH(NOLOCK,READUNCOMMITTED)
	ON pp.StateName = ls.StateName 
	LEFT JOIN
	[Lookup].[AddressProofType] apt WITH(NOLOCK,READUNCOMMITTED)
	ON pp.AddressProofTypeId= apt.Id and apt.IsDeleted=0
	LEFT JOIN
	[Lookup].[IncomeGroup] ign WITH(NOLOCK,READUNCOMMITTED)
	ON pp.IncomeGroupId= ign.Id and ign.IsDeleted=0
	LEFT JOIN
	[Lookup].[Occupation] oo WITH(NOLOCK,READUNCOMMITTED)
	ON pp.OccupationId= oo.Id and oo.IsDeleted=0
	LEFT JOIN
	[Lookup].[RelationshipType] rt WITH(NOLOCK,READUNCOMMITTED)
	ON pp.RelationshipTypeId= rt.Id and rt.IsDeleted=0
	LEFT JOIN
	[Lookup].[Religion] rn WITH(NOLOCK,READUNCOMMITTED)
	ON pp.ReligionId= rn.Id and rn.IsDeleted=0
	LEFT JOIN
	[Lookup].[Education] en WITH(NOLOCK,READUNCOMMITTED)
	ON pp.EducationId = en.Id and en.IsDeleted=0
	LEFT JOIN
	[dbo].[Users] du WITH(NOLOCK,READUNCOMMITTED)
	ON du.UserId=pp.UserId 	AND du.IsDeleted=0
Where
    pp.IsDeleted=0
	AND
	lc.IsDeleted=0
	AND 
	ls.IsDeleted=0
	AND
	pp.Guid=@PatientGuid

SELECT 
    pp.Guid as PatientGuid,
    pp.Id as PatientId,
    pp.Title,
    CONCAT(pp.[FirstName],' ',pp.[MiddleName],' ',pp.[LastName]) as PatientName,
    mpv.VitalName,
    mpv.VitalValue,
    mpv.LastUpdatedTime
FROM
    [Patient].[Patient] pp WITH(NOLOCK, READUNCOMMITTED)
INNER JOIN
    [mapping].[PatientVitals] mpv WITH(NOLOCK, READUNCOMMITTED) ON mpv.PatientId = pp.Id
INNER JOIN
    (
        SELECT PatientId, MAX(LastUpdatedTime) AS MaxLastUpdatedTime
        FROM [mapping].[PatientVitals]
        GROUP BY PatientId
    ) maxvital ON mpv.PatientId = maxvital.PatientId AND mpv.LastUpdatedTime = maxvital.MaxLastUpdatedTime
WHERE
    pp.IsDeleted = 0
    AND mpv.IsDeleted = 0
    AND pp.Guid = @PatientGuid


SELECT 
     pp.Guid as PatientGuid,
	 pp.Id as PatientId,
	 pp.Title,
	 CONCAT(pp.[FirstName],' ',pp.[MiddleName],' ',pp.[LastName]) as PatientName,
	 dd.Guid as DoctorGuid,
	 CONCAT(dd.[FirstName],' ',dd.[LastName]) as DoctorName,
	 cc.Guid as CoordinatorGuid,
	 CONCAT(cc.[FirstName],' ',cc.[LastName]) as CoordinatorName,
	 pa.Guid as AppointmentGuid,
	 pa.AppointmentDate,
	 pa.AppointmentName,
	 pa.Description,
	 mp.Symptoms,
	 mp.SeverityLevel,
	 mp.Description as SymptomDescription,  
	 CASE WHEN pa.IsPatientAttended = 1 THEN 'true' ELSE 'false' END AS IsPatientAttended ,
	 CASE WHEN pa.IsCoordinatorAttended = 1 THEN 'true' ELSE 'false' END AS IsCoordinatorAttended,
	 CASE WHEN pa.IsDoctorAttended = 1 THEN 'true' ELSE 'false' END AS IsDoctorAttended,
	 CASE WHEN pa.IsRescheduled = 1 THEN 'true' ELSE 'false' END AS IsRescheduled,
	 pa.VideoUrl,
	 pa.AppointmentDuration
FROM
    [Patient].[Patient] pp WITH(NOLOCK,READUNCOMMITTED)
	INNER JOIN
	[Patient].[Appointment] pa WITH(NOLOCK,READUNCOMMITTED)
	ON pa.PatientId = pp.Id
	INNER JOIN
    [doctor].[doctor] dd WITH(NOLOCK,READUNCOMMITTED)
	on dd.Id= pa.DoctorId 
	INNER JOIN
    [Coordinator].[Coordinator] cc WITH(NOLOCK,READUNCOMMITTED)
	on cc.Id= pa.CoordinatorId 
	INNER JOIN
	[mapping].[PatientSymptoms] mp WITH(NOLOCK,READUNCOMMITTED)
	on mp.AppointmentId = pa.Id
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
	pa.IsDeleted=0
	AND
	du1.IsDeleted=0
	AND
	du2.IsDeleted=0
	AND
	du3.IsDeleted=0
	AND
	dd.IsDeleted=0
	AND
	cc.IsDeleted=0
	AND
	mp.IsDeleted=0
	AND
	pp.Guid=@PatientGuid

/* Patient Doctor Prescribed Investigations */
SELECT 
    dd.Guid AS DoctorGuid,
	CONCAT(dd.[FirstName],' ',dd.[LastName]) as DoctorName,
	cc.Guid as CoordinatorGuid,
	CONCAT(cc.[FirstName],' ',cc.[LastName]) as CoordinatorName,
	pp.Guid as PatientGuid,
	CONCAT(pp.[FirstName],' ',pp.[MiddleName],' ',pp.[LastName]) as PatientName,
	pa.Guid as AppointmentGuid,
	pa.AppointmentDate,
    mp.Investigations,
	mp.Status
FROM
    [mapping].[PatientInvestigations] mp WITH(NOLOCK,READUNCOMMITTED)
	INNER JOIN
	[Patient].[Appointment] pa WITH(NOLOCK,READUNCOMMITTED)
	ON pa.Id = mp.AppointmentId
	INNER JOIN
    [Patient].[Patient] pp WITH(NOLOCK,READUNCOMMITTED)
	on pp.Id= mp.PatientId 
	INNER JOIN
    [Doctor].[Doctor] dd WITH(NOLOCK,READUNCOMMITTED)
	on dd.Id= mp.DoctorId 
	INNER JOIN
    [Coordinator].[Coordinator] cc WITH(NOLOCK,READUNCOMMITTED)
	on cc.Id= pa.CoordinatorId
WHERE
   pa.IsDeleted=0
	AND
   mp.IsDeleted=0
    AND
   dd.IsDeleted=0
    AND
   pp.IsDeleted=0
    AND
   pp.Guid=@PatientGuid

SET NOCOUNT OFF

END
GO


CREATE procedure [dbo].[spGetSpecificUserDetails]  
  @UserGuid uniqueIdentifier
  
AS        
      
/*
 exec [dbo].[spGetSpecificUserDetails] @UserGuid='80378182-c7a9-4742-aa4d-704953c30f49'
 -------------------------------------------------------------              

 MODIFICATIONS        
 Date					Author				Description          
 -----------------------------------------------------------------------------
20/04/2023			   M.Chandrani	           to get specific user information
 ------------------------------------------------------------------------------      
                Copyright 2023@YLIMS
*/        
BEGIN 

SET NOCOUNT ON

DECLARE @UserId INT
SELECT @UserId=UserId from dbo.Users where UserGuid=@UserGuid 

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
	 dd.IsAvailable,
	 dd.CreatedDt 
 FROM 
	[Doctor].[Doctor] dd WITH(NOLOCK,READUNCOMMITTED)
	INNER JOIN
	[Lookup].[City] lc WITH(NOLOCK,READUNCOMMITTED)
	ON dd.City = lc.CityName 
	INNER JOIN
	[Lookup].[State] ls WITH(NOLOCK,READUNCOMMITTED)
	ON dd.State = ls.StateName
	left JOIN
	[Lookup].[State] lsr WITH(NOLOCK,READUNCOMMITTED)
	ON dd.StateOfRegistration=lsr.StateName and lsr.IsDeleted=0
	INNER JOIN
	[dbo].[Users] du WITH(NOLOCK,READUNCOMMITTED)
	ON du.UserId=dd.UserId
 WHERE 
	dd.IsDeleted=0
	AND 
	lc.IsDeleted=0
	AND 
	ls.IsDeleted=0
	AND
	du.IsDeleted=0
	AND
	dd.UserId=@UserId

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
	 pp1.Guid as RelationGuid,
     pp.MothersMaidenName,
	 lc.Guid as CityGuid,
     pp.CityName,
	 ls.Guid as StateGuid,
     pp.StateName,
     pp.Address1,
     pp.Address2,
     pp.PatientPhotoURL,
	 pp.CreatedByUserId,
	 du.CreatedDt,
	 (select COUNT(id) from [Patient].[Appointment] pa where pa.PatientId =pp.Id and   pa.IsDoctorSelected =0 and
	 pa.IsDeleted = 0 AND ((pa.IsCoordinatorAttended = 0 AND pa.IsPatientAttended=0) AND pa.IsDoctorAttended = 0 and pa.IsConfirmed=1) AND pa.AppointmentDate >= CONVERT(DATETIME, SWITCHOFFSET(GETUTCDATE(), '+05:30'))) as 'UpcomingCount',
	 (select top 1 pa.guid  from [Patient].[Appointment] pa where pa.PatientId =pp.Id and   pa.IsDoctorSelected =0 and
	 pa.IsDeleted = 0 AND ((pa.IsCoordinatorAttended = 0 AND pa.IsPatientAttended=0) AND pa.IsDoctorAttended = 0) AND pa.AppointmentDate >= CONVERT(DATETIME, SWITCHOFFSET(GETUTCDATE(), '+05:30')))  as 'UpcomingAppointmentGuid'
FROM 
	[Patient].[Patient] pp WITH(NOLOCK,READUNCOMMITTED)
    LEFT JOIN
	[Patient].[Patient] pp1 WITH(NOLOCK,READUNCOMMITTED)
	ON pp.RelationId=pp1.Id
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
	INNER JOIN
	[dbo].[Users] du WITH(NOLOCK,READUNCOMMITTED)
	ON du.UserId=pp.UserId
Where
    pp.IsDeleted=0
	AND
	lc.IsDeleted=0
	AND 
	ls.IsDeleted=0
	AND 
	du.IsDeleted=0
	AND
	pp.UserId=@UserId
    ORDER BY
    CASE WHEN pp.RelationId IS NULL THEN 0 ELSE 1 END, pp.RelationId;


SELECT
     cc.Guid as CoordinatorGuid,
	 cc.UserId,
	 du.UserName,
	 du.PasswordHash,
	 cc.FirstName,
	 cc.LastName,
	 cc.ContactNumber,
	 cc.AlternateNumber,
	 cc.EmailId,
	 cc.Gender,
     CONVERT(varchar, cc.DateOfBirth, 105) as DateOfBirth,
	 cc.Branches,
	 cc.WorkDays,
	 cc.WorkHours,
	 cc.PreferredContactType,
	 cc.Languages,
	 cc.CoordinatorPhotoURL,
	 cc.CreatedDt 
 FROM 
	[Coordinator].[Coordinator] cc WITH(NOLOCK,READUNCOMMITTED)
	INNER JOIN
	[dbo].[Users] du WITH(NOLOCK,READUNCOMMITTED)
	ON du.UserId=cc.UserId
 WHERE 
	(cc.IsDeleted=0
	AND
	du.IsDeleted=0)
	AND
	cc.UserId=@UserId

SET NOCOUNT OFF
END
GO


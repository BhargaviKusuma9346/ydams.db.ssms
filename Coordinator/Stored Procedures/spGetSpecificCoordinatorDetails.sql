
CREATE procedure [Coordinator].[spGetSpecificCoordinatorDetails]  
  @CoordinatorGuid uniqueIdentifier=null,
  @UserGuid uniqueIdentifier=null
  
AS        
      
/*
 exec [Coordinator].[spGetSpecificCoordinatorDetails]    @UserGuid='8C2A320D-007F-456D-9770-33A2431C704A'
 select * from Coordinator.Coordinator where Guid='97CC8692-B35B-4F41-A437-368BE0D137E0'
 -------------------------------------------------------------              

 MODIFICATIONS        
 Date					Author				Description          
 -----------------------------------------------------------------------------
20/04/2023			   M.Chandrani	           to get specific Coordinator information
 ------------------------------------------------------------------------------      
                Copyright 2023@YLIMS
*/        
BEGIN 

SET NOCOUNT ON

DECLARE @UserId INT
IF @UserGuid is not null
BEGIN
  SELECT @UserId=UserId from dbo.users WITH(NOLOCK,READUNCOMMITTED) where UserGuid=@UserGuid
END

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
	(cc.Guid=@CoordinatorGuid or cc.UserId=@UserId)

SELECT 
    cc.Guid AS CoordinatorGuid,
    cc.FirstName,
    cc.LastName,
    ll.Guid AS LanguageGuid,
    ll.Languages AS Languages
FROM
    [Coordinator].[Coordinator] cc WITH(NOLOCK,READUNCOMMITTED)
    CROSS APPLY STRING_SPLIT(cc.Languages, ',') AS l
    INNER JOIN [Lookup].[Languages] ll WITH(NOLOCK,READUNCOMMITTED)
        ON l.value = ll.Languages
WHERE
   cc.IsDeleted=0
   AND
   ll.IsDeleted=0
   AND
   (cc.Guid=@CoordinatorGuid or cc.UserId=@UserId)

SELECT 
    cc.Guid AS CoordinatorGuid,
    cc.FirstName,
    cc.LastName,
    lp.Guid AS PreferredContactTypeGuid,
    lp.PreferredContactType AS PreferredContactType
FROM
    [Coordinator].[Coordinator] cc WITH(NOLOCK,READUNCOMMITTED)
    CROSS APPLY STRING_SPLIT(cc.PreferredContactType, ',') AS l
    INNER JOIN [Lookup].[PreferredContactType] lp WITH(NOLOCK,READUNCOMMITTED)
        ON l.value = lp.PreferredContactType
WHERE
   cc.IsDeleted=0
   AND
   lp.IsDeleted=0
   AND
   (cc.Guid=@CoordinatorGuid or cc.UserId=@UserId)

SELECT 
    cc.Guid AS CoordinatorGuid,
    cc.FirstName,
    cc.LastName,
    lb.Guid AS BranchGuid,
    lb.BranchName AS BranchName,
	lb.Address AS BranchAddress,
	lb.Latitude,
	lb.Longitude,
	CASE WHEN mcb.IsDefault=1 THEN 'true' else 'false' END AS IsDefaultBranch
FROM 
    [Mapping].[CoordinatorBranches] mcb WITH(NOLOCK,READUNCOMMITTED)
	INNER JOIN 
    [Coordinator].[Coordinator] cc WITH(NOLOCK,READUNCOMMITTED)
	on mcb.CoordinatorId=cc.Id
    INNER JOIN 
	[Lookup].[Branch] lb WITH(NOLOCK,READUNCOMMITTED)
        ON mcb.BranchId = lb.Id
WHERE
   cc.IsDeleted=0
   AND
   lb.IsDeleted=0
   AND 
   mcb.IsDeleted=0
   AND
   (cc.Guid=@CoordinatorGuid or cc.UserId=@UserId)

SELECT 
     cc.Guid as CoordinatorGuid,
	 CONCAT(cc.[FirstName],' ',cc.[LastName]) as CoordinatorName,
	 dd.Guid as DoctorGuid,
	 CONCAT(dd.[FirstName],' ',dd.[LastName]) as DoctorName,
	 pp.Guid as PatientGuid,
	 CONCAT(pp.[FirstName],' ',pp.[MiddleName],' ',pp.[LastName]) as PatientName,	 
	 pa.Guid as AppointmentGuid,
	 pa.AppointmentDate,
	 pa.AppointmentName,
	 pa.Description,
	 CASE WHEN pa.IsPatientAttended = 1 THEN 'true' ELSE 'false' END AS IsPatientAttended ,
	 CASE WHEN pa.IsCoordinatorAttended = 1 THEN 'true' ELSE 'false' END AS IsCoordinatorAttended,
	 CASE WHEN pa.IsDoctorAttended = 1 THEN 'true' ELSE 'false' END AS IsDoctorAttended,
	 CASE WHEN pa.IsRescheduled = 1 THEN 'true' ELSE 'false' END AS IsRescheduled,
	 pa.VideoUrl,
	 pa.AppointmentDuration
FROM
    [Coordinator].[Coordinator] cc WITH(NOLOCK,READUNCOMMITTED)
	INNER JOIN
	[Patient].[Appointment] pa WITH(NOLOCK,READUNCOMMITTED)
	ON pa.CoordinatorId = cc.Id
	INNER JOIN
    [Patient].[Patient] pp WITH(NOLOCK,READUNCOMMITTED)
	on pp.Id= pa.PatientId 
	INNER JOIN
    [Doctor].[Doctor] dd WITH(NOLOCK,READUNCOMMITTED)
	on dd.Id= pa.DoctorId 
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
	(cc.Guid=@CoordinatorGuid or cc.UserId=@UserId)


SET NOCOUNT OFF

END


CREATE procedure [Patient].[spGetSpecificPatientFamilyDetails]
  @PatientGuid uniqueIdentifier
  
AS        
      
/*
 exec [Patient].[spGetSpecificPatientFamilyDetails] @PatientGuid='8e3204fe-af10-40bc-a429-cb2e2cf97ce4'
 select * from patient.patient where Guid='8e3204fe-af10-40bc-a429-cb2e2cf97ce4'
 -------------------------------------------------------------              

 MODIFICATIONS        
 Date					Author				Description          
 -----------------------------------------------------------------------------
20/04/2023			   Ravali           to get specific patient family details
 ------------------------------------------------------------------------------      
                Copyright 2023@YLIMS
*/        
BEGIN 
DECLARE @PatientId Int
SELECT @PatientId= Id  from [Patient].[Patient] where Guid=@PatientGuid
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
     pp.IdentificationNumber,
     pp.ReligionName,
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
	 pp.CreatedByUserId
FROM 
	[Patient].[Patient] pp WITH(NOLOCK,READUNCOMMITTED)
    INNER JOIN
	[Lookup].[City] lc WITH(NOLOCK,READUNCOMMITTED)
	ON pp.CityName = lc.CityName
	INNER JOIN
	[Lookup].[State] ls WITH(NOLOCK,READUNCOMMITTED)
	ON pp.StateName = ls.StateName
	left JOIN
	[Lookup].[RelationshipType] rt WITH(NOLOCK,READUNCOMMITTED)
	ON pp.RelationshipTypeId= rt.Id
	left JOIN
	[dbo].[Users] du WITH(NOLOCK,READUNCOMMITTED)
	ON du.UserId=pp.UserId 	AND du.IsDeleted=0
Where
    pp.IsDeleted=0
	AND
	lc.IsDeleted=0
	AND 
	ls.IsDeleted=0
	AND 
	pp.RelationId in (@PatientId)



SET NOCOUNT OFF

END

CREATE PROCEDURE [Patient].[spGetAddPatientDefaults]

 AS
 
/*

exec [Patient].[spGetAddPatientDefaults]

select * from [Lookup].[Vital]
select * from [Lookup].[AddressProofType] where Guid = '83908ca0-9338-452b-a519-5f660b3affed'
select * from [Lookup].[City]
select * from [Lookup].[State]
select * from [Lookup].[IncomeGroup]
select * from [Lookup].[Occupation]
select * from [Lookup].[RelationshipType]
select * from [Lookup].[Religion] where Guid= '00000000-0000-0000-0000-000000000000'
select * from [Lookup].[Education]

 MODIFICATIONS        
 Date					Author				Description          
 -----------------------------------------------------------------------------
 19/04/2023			M Chandrani	           Get all Defaults for Addition of Patients
 ------------------------------------------------------------------------------      
                Copyright 2023@YodaLIMS
*/ 

BEGIN
SET NOCOUNT ON
/*Main Query */

SELECT
	Guid as VitalGuid,
	VitalName,
	Description
FROM 
	[Lookup].[Vital] WITH(NOLOCK,READUNCOMMITTED)
WHERE 
	IsDeleted=0

SELECT
	Guid as AddressProofTypeGuid,
	AddressProofType
FROM 
	[Lookup].[AddressProofType] WITH(NOLOCK,READUNCOMMITTED)
WHERE 
	IsDeleted=0 order by AddressProofType asc

SELECT
    c.Guid as CityGuid,
    c.CityName,
    s.Guid as StateGuid
FROM 
	[Lookup].[City] c WITH(NOLOCK,READUNCOMMITTED)
	INNER JOIN 
	[Lookup].[State] s WITH(NOLOCK,READUNCOMMITTED)
	on 
	s.Id=c.StateId

WHERE 
	c.IsDeleted=0 and
	s.IsDeleted=0 order by CityName asc

SELECT
	Guid as StateGuid,
	StateName 
FROM 
	[Lookup].[State] WITH(NOLOCK,READUNCOMMITTED)
WHERE 
	IsDeleted=0 order by StateName asc


SELECT
	Guid as IncomeGroupGuid,
	IncomeGroupName 
FROM 
	[Lookup].[IncomeGroup] WITH(NOLOCK,READUNCOMMITTED)
WHERE 
	IsDeleted=0 order by IncomeGroupName asc

SELECT
	Guid as OccupationGuid,
	OccupationName
FROM 
	[Lookup].[Occupation] WITH(NOLOCK,READUNCOMMITTED)
WHERE 
	IsDeleted=0 order by OccupationName asc


SELECT
	Guid as RelationshipTypeGuid,
	RelationshipType 
FROM 
	[Lookup].[RelationshipType] WITH(NOLOCK,READUNCOMMITTED)
WHERE 
	IsDeleted=0 


SELECT
	Guid as ReligionGuid,
	ReligionName 
FROM 
	[Lookup].[Religion] WITH(NOLOCK,READUNCOMMITTED)
WHERE 
	IsDeleted=0 order by ReligionName asc


SELECT
	Guid as EducationGuid,
	EducationName 
FROM 
	[Lookup].[Education] WITH(NOLOCK,READUNCOMMITTED)
WHERE 
	IsDeleted=0 order by EducationName asc

SELECT
	Guid as PastHistoryTypeGuid,
	PastHistoryFieldName,
	Description
FROM 
	[Lookup].[PastHistoryType] WITH(NOLOCK,READUNCOMMITTED)
WHERE 
	IsDeleted=0 order by PastHistoryFieldName asc

SELECT
	Guid as PastHistoryQuestionTypeGuid,
	QuestionType,
	OptionCount
FROM 
	[Lookup].[PastHistoryQuestionType] WITH(NOLOCK,READUNCOMMITTED)
WHERE 
	IsDeleted=0 order by QuestionType asc

SELECT
	Guid as DiagnosisGroupGuid,
	DiagnosisGroup
FROM 
	[Lookup].[DiagnosisGroup] WITH(NOLOCK,READUNCOMMITTED)
WHERE 
	IsDeleted=0

SET NOCOUNT OFF
END
GO


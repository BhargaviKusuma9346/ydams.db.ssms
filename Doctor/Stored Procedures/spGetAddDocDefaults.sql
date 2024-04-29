CREATE PROCEDURE [Doctor].[spGetAddDocDefaults]

 AS


 
/*

exec [Doctor].[spGetAddDocDefaults]
 select * from [Lookup].[DrQualification]
select * from [Lookup].[DrSpecialization]

exec [Doctor].[spGetAddDocDefaults]

 MODIFICATIONS        
 Date					Author				Description          
 -----------------------------------------------------------------------------
 07/04/2023			K Jacob Paul	           Gey all Defaults for Addtion of doctors
 ------------------------------------------------------------------------------      
                Copyright 2023@YodaLIMS
*/ 

BEGIN
SET NOCOUNT ON
/*Main Query */

 SELECT 
	 Guid as LanguageGuid ,
	 Languages
 FROM 
	[Lookup].[Languages] WITH(NOLOCK,READUNCOMMITTED)
 WHERE 
	IsDeleted=0 order by Languages asc


 SELECT 
	 Guid as QualificationGuid ,
	 QualificationName
 FROM 
	[Lookup].[DrQualification] WITH(NOLOCK,READUNCOMMITTED)
 WHERE 
	IsDeleted=0 order by QualificationName asc


SELECT
	Guid as SpecializationGuid,
	SpecializationName 
FROM 
	[Lookup].[DrSpecialization] WITH(NOLOCK,READUNCOMMITTED)
WHERE 
	IsDeleted=0 order by SpecializationName asc

SELECT
	Guid as StateGuid,
	StateName 
FROM 
	[Lookup].[State] WITH(NOLOCK,READUNCOMMITTED)
WHERE 
	IsDeleted=0 order by StateName asc


select 
c.Guid as CityGuid,
c.CityName,
s.Guid as StateGuid
from 
	[Lookup].[City] c WITH(NOLOCK,READUNCOMMITTED)
	inner join 
	Lookup.State s WITH(NOLOCK,READUNCOMMITTED)
	on 
	s.Id=c.StateId

WHERE 
	c.IsDeleted=0 and
	s.IsDeleted=0 order by CityName asc


SET NOCOUNT OFF
END
GO


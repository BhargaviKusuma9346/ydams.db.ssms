CREATE PROCEDURE [Coordinator].[spGetAddCoordinatorDefaults]

 AS

/*

exec [Coordinator].[spGetAddCoordinatorDefaults]

 MODIFICATIONS        
 Date					Author				Description          
 ---------------------------------------------------------------------------------------
 21/04/2023			M Chandrani	           Get all Defaults for Addtion of Coordinators
 ---------------------------------------------------------------------------------------     
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
	IsDeleted=0
	order by Languages asc

SELECT 
	 Guid as PreferredContactTypeGuid ,
	 PreferredContactType
 FROM 
	[Lookup].[PreferredContactType] WITH(NOLOCK,READUNCOMMITTED)
 WHERE 
	IsDeleted=0

SELECT
    lb.Guid as BranchGuid,
	lb.BranchName,
	lb.Address as BranchAddress,
	lb.Latitude as Latitude,
	lb.Longitude as Longitude,
    lb.City,
	lb.State
FROM
    [Lookup].[Branch] lb WITH(NOLOCK,READUNCOMMITTED)
WHERE
    lb.IsDeleted=0 
	order by lb.BranchName asc

SELECT
	Guid as StateGuid,
	StateName 
FROM 
	[Lookup].[State] WITH(NOLOCK,READUNCOMMITTED)
WHERE 
	IsDeleted=0

SELECT
    c.Guid as CityGuid,
    c.CityName,
    s.Guid as StateGuid
FROM
	[Lookup].[City] c WITH(NOLOCK,READUNCOMMITTED)
	inner join 
	[Lookup].[State] s WITH(NOLOCK,READUNCOMMITTED)
	on 
	s.Id=c.StateId

WHERE 
	c.IsDeleted=0 and
	s.IsDeleted=0


SET NOCOUNT OFF
END
GO


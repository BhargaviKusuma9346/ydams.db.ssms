
CREATE PROCEDURE [dbo].[spGetInvestMedDefaults]

 AS

/*

exec [dbo].[spGetInvestMedDefaults]

 MODIFICATIONS        
 Date					Author				Description          
 ---------------------------------------------------------------------------------------
 21/04/2023			M Chandrani	           Get all Defaults for Addition of Medications and Investigations
 ---------------------------------------------------------------------------------------     
                Copyright 2023@YodaLIMS
*/ 

BEGIN
SET NOCOUNT ON
/*Main Query */

SELECT 
     Guid as MedicationTypeGuid,
	 MedicationType
 FROM 
	[Lookup].[MedicationType] WITH(NOLOCK,READUNCOMMITTED)
 WHERE 
	IsDeleted=0

SELECT 
     Guid as SpecimenTypeGuid,
	 SpecimenType
 FROM 
	[Lookup].[SpecimenType] WITH(NOLOCK,READUNCOMMITTED)
 WHERE 
	IsDeleted=0

SELECT 
     Guid as TestCategoryGuid,
	 TestCategory
 FROM 
	[Lookup].[TestCategory] WITH(NOLOCK,READUNCOMMITTED)
 WHERE 
	IsDeleted=0


SET NOCOUNT OFF
END




  




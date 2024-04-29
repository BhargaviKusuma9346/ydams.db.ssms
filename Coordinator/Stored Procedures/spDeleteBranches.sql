CREATE procedure [Coordinator].[spDeleteBranches] 
  @BranchGuid uniqueIdentifier,
  @TargetBranchGuid uniqueIdentifier=null

AS        
      
/*
 exec [Coordinator].[spDeleteBranches]   @BranchGuid='09D6CF8C-4D64-47FC-90E4-FA22C715131D',@TargetBranchGuid='6A49D7B3-A2ED-40FF-9E64-82824F746B53'
 -------------------------------------------------------------              
	select * from [Lookup].[Branch] where IsDeleted=1
	select * from [mapping].[CoordinatorBranches]

 MODIFICATIONS        
 Date					Author				Description          
 -----------------------------------------------------------------------------
20/04/2023			   M.Chandrani	           to delete Branch Details
 ------------------------------------------------------------------------------      
                Copyright 2023@YLIMS
*/        
BEGIN 

SET NOCOUNT ON

DECLARE @TargetBranchId INT,@BranchId INT
SELECT @TargetBranchId=Id from Lookup.Branch where Guid=@TargetBranchGuid
SELECT @BranchId=Id from Lookup.Branch where Guid=@BranchGuid

IF @TargetBranchGuid IS NOT NULL
BEGIN
;WITH cte_name AS (
  SELECT
    CoordinatorId,
    (
      SELECT COUNT(*)
      FROM [mapping].[CoordinatorBranches]
      WHERE CoordinatorId = a.CoordinatorId AND IsDeleted = 0
    ) AS countBranches
  FROM [mapping].[CoordinatorBranches] a
  WHERE BranchId = @BranchId AND IsDeleted = 0
)

UPDATE cb
SET
  BranchId = CASE
    WHEN CoordinatorId IN (SELECT CoordinatorId FROM cte_name WHERE countBranches = 1) THEN @TargetBranchId
    ELSE BranchId
  END,
  IsDeleted = CASE
    WHEN CoordinatorId IN (SELECT CoordinatorId FROM cte_name WHERE countBranches > 1) THEN
      CASE
        WHEN BranchId = @BranchId THEN 1
        ELSE IsDeleted
      END
    ELSE IsDeleted
  END,
  IsDefault = CASE
    WHEN CoordinatorId IN (SELECT CoordinatorId FROM cte_name WHERE countBranches > 1) THEN
      CASE
        WHEN BranchId = (
          SELECT TOP 1 BranchId
          FROM [mapping].[CoordinatorBranches]
          WHERE CoordinatorId = cb.CoordinatorId AND IsDeleted = 0 AND BranchId<>@BranchId
          ORDER BY CoordinatorId
        ) THEN 1
        ELSE IsDefault
      END
    ELSE IsDefault
  END
FROM [mapping].[CoordinatorBranches] cb
WHERE cb.CoordinatorId IN (SELECT CoordinatorId FROM cte_name);

;WITH cte_branches AS (
  SELECT
    CoordinatorId,
    STRING_AGG(lb.BranchName, ',') AS Branches
  FROM 
  [mapping].[CoordinatorBranches] mcb
  inner join
  [Lookup].[Branch] lb 
  on 
  mcb.BranchId=lb.Id
  WHERE 
  mcb.IsDeleted = 0 
  and 
  lb.Isdeleted=0
  GROUP BY 
  CoordinatorId
)

UPDATE cc
SET
    cc.Branches = cte.Branches
FROM 
     [Coordinator].[Coordinator] cc
INNER JOIN 
     cte_branches cte 
    ON cc.Id = cte.CoordinatorId;
END

UPDATE
   Lookup.Branch
SET
   IsDeleted=1
WHERE
   Guid = @BranchGuid

SET NOCOUNT OFF

END
GO


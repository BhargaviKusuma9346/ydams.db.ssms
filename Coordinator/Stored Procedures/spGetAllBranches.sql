CREATE PROCEDURE [Coordinator].[spGetAllBranches]
  @PageNumber int=-1,
  @RowCount int=-1,
  @Keyword varchar(max)='',
  @OrderBy varchar(200) = '',
  @SortType varchar(5)='asc'

 AS

 /*

exec [Coordinator].[spGetAllBranches] @PageNumber=1,@RowCount='',@Keyword='',@OrderBy='',@SortType='desc'

select * from [Lookup].[Branch] 

 MODIFICATIONS        
 Date					Author				Description          
 -----------------------------------------------------------------------------
 18/04/2023			M Chandrani	           Get all Details of Branches
 ------------------------------------------------------------------------------      
                Copyright 2023@YodaLIMS
*/ 

BEGIN
SET NOCOUNT ON

/*Main Query */
DECLARE @Query nvarchar(max)=''
DECLARE @SQL nvarchar(max)=''
DECLARE @SeletClause nvarchar(max)=''
DECLARE @WhereClause nvarchar(max)=''
DECLARE @OrderByClause nvarchar(max)=''
DECLARE @FinalOrderBy nvarchar(max)=''
DECLARE @OffsetClause nvarchar(max)=''
DECLARE @AdditionalQuery nvarchar(max)
SET @Keyword = IIF(@Keyword is null, '', TRIM(@Keyword))

If(@SortType = '' or @SortType is null)
BEGIN
	SET @SortType = 'asc'
END
	SET @SQL+=
   ';WITH tblCoordinators(BranchGuid,BranchName,BranchAddress,City,State,Latitude,Longitude,BranchContactPerson,BranchContactEmail,BranchContactPhone,CreatedDt,CoordinatorCount) as
	( 
	 SELECT 
	  lb.Guid as BranchGuid,
	  lb.BranchName,
	  lb.Address as BranchAddress,
	  lb.City as City,
	  lb.State as State,
	  lb.Latitude as Latitude,
	  lb.Longitude as Longitude,
	  lb.ContactName as BranchContactPerson,
	  lb.ContactEmail as BranchContactEmail,
	  lb.ContactPhone as BranchContactPhone,
	  lb.CreatedDt,
	  (SELECT count(*) from mapping.coordinatorbranches mcb inner join coordinator.coordinator cc on cc.id=mcb.CoordinatorId where cc.Isdeleted=0 and mcb.Isdeleted=0 and mcb.BranchId=lb.Id)
 FROM 
	[Lookup].[Branch] lb WITH(NOLOCK,READUNCOMMITTED)
 WHERE 
	lb.IsDeleted=0 '

  IF (@Keyword !=''  )
	BEGIN 
	SET @WhereClause+='and (BranchName LIKE ''%'+ @Keyword +'%'' or Address LIKE ''%'+ @Keyword +'%'' or ContactName LIKE ''%'+ @Keyword +'%'' or ContactPhone LIKE ''%'+ @Keyword +'%'' or ContactEmail LIKE ''%'+ @Keyword +'%'')'
	END

  IF(@OrderBy='Branch name ' )
  BEGIN
  SET @OrderByClause+=' order by BranchName '+ @SortType
  SET @FinalOrderBy +=' order by BranchName '+ @SortType
  END

 IF(@OrderBy is null or @OrderBy = '')
  BEGIN
  SET @OrderByClause+=' order by CreatedDt '+ @SortType
  SET @FinalOrderBy +=' order by CreatedDt DESC '
  END 

  IF (@PageNumber=-1 or @RowCount='')
  BEGIN
     SET @OffsetClause =' OFFSET 0 ROWS'
  END

  IF (@PageNumber !=-1 and @RowCount!='')
  BEGIN

		SET @OffsetClause =' OFFSET '+ (CAST( (@PageNumber-1)*(@RowCount) AS nvarchar(200))) +' ROWS 
		FETCH NEXT '+ (CAST(@RowCount AS nvarchar(200))) +' ROWS ONLY ' 
  END

  SET @AdditionalQuery=' SELECT * '

  SET @AdditionalQuery+=',(Select count(DISTINCT lb.Guid )	 	
		                    FROM 
	                          [Lookup].[Branch] lb WITH(NOLOCK,READUNCOMMITTED)
                               WHERE 
							    lb.IsDeleted=0 '
							 + @WhereClause+ ' ) as TotalCount '

SET @AdditionalQuery+=' from tblCoordinators tcs'
 
  SET @Query+= @SQL + @WhereClause  + @OrderByClause + @OffsetClause+ ')' + @AdditionalQuery + @FinalOrderBy
	
  PRINT @Query

EXECUTE sp_executesql @Query


 SET NOCOUNT OFF
END
GO


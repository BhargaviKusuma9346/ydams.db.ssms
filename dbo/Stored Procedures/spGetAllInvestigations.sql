CREATE PROCEDURE [dbo].[spGetAllInvestigations] 
  @PageNumber int=-1,
  @RowCount int=-1,
  @Keyword varchar(max)='',
  @OrderBy varchar(200) = '',
  @SortType varchar(5)='asc',
  @UserGuid uniqueIdentifier=null

 AS

 /*

exec [dbo].[spGetAllInvestigations]  @PageNumber=1,@RowCount='',@Keyword='',@OrderBy='',@SortType='desc',@UserGuid=null

select * from lookup.investigations 
select * from [Lookup].[Investigations] order by 1 desc

 MODIFICATIONS        
 Date					Author				Description          
 -----------------------------------------------------------------------------
 18/04/2023			M Chandrani	           Get all Details of Investigations
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

DECLARE @UserId varchar(100)
SELECT @UserId=UserId from dbo.Users where UserGuid=@UserGuid

SET @Keyword = IIF(@Keyword is null, '', TRIM(@Keyword))

If(@SortType = '' or @SortType is null)
BEGIN
	SET @SortType = 'asc'
END
	SET @SQL+=
   ';WITH tblInvestigations(InvestigationsGuid,CreatedByUserGuid,TestCode,TestName,TestCategory,SpecimenType,SpecimenVolume,Instructions,CreatedByUserId,CreatedDt) as
	( 
	 SELECT 
	  li.Guid as InvestigationsGuid,
	  du.UserGuid as CreatedByUserGuid,
	  li.TestCode,
	  li.TestName,
	  li.TestCategory,
	  li.SpecimenType,
      li.SpecimenVolume,
      li.Instructions,
	  li.CreatedByUserId,
	  li.CreatedDt
 FROM 
	[Lookup].[Investigations] li WITH(NOLOCK,READUNCOMMITTED)
	LEFT JOIN
	[dbo].[Users] du WITH(NOLOCK,READUNCOMMITTED)
	ON du.UserId=li.CreatedByUserId AND du.IsDeleted=0
 WHERE 
	 li.IsDeleted=0 '

  IF (@Keyword !=''  )
	BEGIN 
	SET @WhereClause+='and (TestName LIKE ''%'+ @Keyword +'%'' or SpecimenType LIKE ''%'+ @Keyword +'%'' or TestCategory LIKE ''%'+ @Keyword +'%'' or TestCode LIKE ''%'+ @Keyword +'%'')'
	END

  IF (@UserGuid is not null)
	BEGIN 
	SET @WhereClause+=' AND (CreatedByUserId LIKE ''%'+ @UserId +'%'')'
	END

  IF(@OrderBy='Test name ' )
  BEGIN
  SET @OrderByClause+=' order by TestName '+ @SortType
  SET @FinalOrderBy +=' order by TestName '+ @SortType
  END

  IF(@OrderBy='Specimen type ' )
  BEGIN
  SET @OrderByClause+=' order by Specimen Type '+ @SortType
  SET @FinalOrderBy +=' order by Specimen Type '+ @SortType
  END

    IF(@OrderBy='Test category' )
  BEGIN
  SET @OrderByClause+=' order by TestCategory '+ @SortType
  SET @FinalOrderBy +=' order by TestCategory '+ @SortType
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

  SET @AdditionalQuery+=',(Select count(DISTINCT Guid )	 	
		                    FROM 
	                          [Lookup].[Investigations] li WITH(NOLOCK,READUNCOMMITTED)
                               LEFT JOIN
								[dbo].[Users] du WITH(NOLOCK,READUNCOMMITTED)
								ON du.UserId=li.CreatedByUserId AND du.IsDeleted=0
                               WHERE 
							    li.IsDeleted=0 
								'
							 + @WhereClause+ ' ) as TotalCount '

SET @AdditionalQuery+=' from tblInvestigations tls'
 
  SET @Query+= @SQL + @WhereClause  + @OrderByClause + @OffsetClause+ ')' + @AdditionalQuery + @FinalOrderBy
	
  PRINT @Query

EXECUTE sp_executesql @Query


 SET NOCOUNT OFF
END
GO


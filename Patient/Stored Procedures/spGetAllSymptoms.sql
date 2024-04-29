
CREATE PROCEDURE [Patient].[spGetAllSymptoms] 
  @PageNumber int=-1,
  @RowCount int=-1,
  @Keyword varchar(max)='',
  @OrderBy varchar(200) = '',
  @SortType varchar(5)='asc'

 AS

 /*
exec [Patient].[spGetAllSymptoms]   @PageNumber=1,@RowCount='',@Keyword='',@OrderBy='',@SortType='desc'


select * from lookup.symptom

 MODIFICATIONS        
 Date					Author				Description          
 -----------------------------------------------------------------------------
 18/04/2023			M Chandrani	           Get all Details of Symptoms
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
   ';WITH tblSymptoms(SymptomGuid,SymptomCode,SymptomName,SymptomType,Description,CreatedDt) as
	( 
	 SELECT 
	  Guid as SymptomGuid,
	  SymptomCode,
	  SymptomName,
	  SymptomType,
	  Description,
	  CreatedDt
 FROM 
	[Lookup].[Symptom] WITH(NOLOCK,READUNCOMMITTED)
 WHERE 
	 IsDeleted=0 '

  IF (@Keyword !=''  )
	BEGIN 
	SET @WhereClause+='and (SymptomName LIKE ''%'+ @Keyword +'%'' or SymptomType LIKE ''%'+ @Keyword +'%'' or Description LIKE ''%'+ @Keyword +'%'' or SymptomCode LIKE ''%'+ @Keyword +'%'')'
	END

  IF(@OrderBy='SymptomName ' )
  BEGIN
  SET @OrderByClause+=' order by SymptomName '+ @SortType
  SET @FinalOrderBy +=' order by SymptomName '+ @SortType
  END

  IF(@OrderBy='SymptomType  ' )
  BEGIN
  SET @OrderByClause+=' order by SymptomType  '+ @SortType
  SET @FinalOrderBy +=' order by SymptomType  '+ @SortType
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

  SET @AdditionalQuery+=',(Select count(DISTINCT Guid)	 	
		                    FROM 
	                          [Lookup].[Symptom] WITH(NOLOCK,READUNCOMMITTED)
                               WHERE 
							    IsDeleted=0 '
							 + @WhereClause+ ' ) as TotalCount '

SET @AdditionalQuery+=' from tblSymptoms tsm'
 
  SET @Query+= @SQL + @WhereClause  + @OrderByClause + @OffsetClause+ ')' + @AdditionalQuery + @FinalOrderBy
	
  PRINT @Query

EXECUTE sp_executesql @Query


 SET NOCOUNT OFF
END
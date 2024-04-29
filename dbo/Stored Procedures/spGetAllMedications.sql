CREATE PROCEDURE [dbo].[spGetAllMedications] 
  @PageNumber int=-1,
  @RowCount int=-1,
  @Keyword varchar(max)='',
  @OrderBy varchar(200) = '',
  @SortType varchar(5)='asc',
  @UserGuid uniqueIdentifier=null

 AS

 /*
exec [dbo].[spGetAllMedications]  @PageNumber=1,@RowCount='',@Keyword='',@OrderBy='',@SortType='desc',@UserGuid=null


select * from lookup.medications

 MODIFICATIONS        
 Date					Author				Description          
 -----------------------------------------------------------------------------
 18/04/2023			M Chandrani	           Get all Details of Medications
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

DECLARE @UserId varchar(100)
SELECT @UserId=UserId from dbo.Users where UserGuid=@UserGuid


If(@SortType = '' or @SortType is null)
BEGIN
	SET @SortType = 'asc'
END
	SET @SQL+=
   ';WITH tblMedications(MedicationsGuid,CreatedByUserGuid,MedicationCode,MedicationName,MedicationClass,Dosage,Type,Manufacturer,Usage,CreatedByUserId,CreatedDt) as
	( 
	 SELECT 
	  lm.Guid as MedicationsGuid,
	  du.UserGuid as CreatedByUserGuid,
	  lm.MedicationCode,
	  lm.MedicationName,
	  lm.MedicationClass,
	  lm.Dosage,
      lm.Type,
      lm.Manufacturer,
	  lm.Usage,
	  lm.CreatedByUserId,
	  lm.CreatedDt
 FROM 
	[Lookup].[Medications] lm WITH(NOLOCK,READUNCOMMITTED)
	LEFT JOIN
	[dbo].[Users] du WITH(NOLOCK,READUNCOMMITTED)
	ON du.UserId=lm.CreatedByUserId AND du.IsDeleted=0 
 WHERE 
	 lm.IsDeleted=0 '

  IF (@Keyword !=''  )
	BEGIN 
	SET @WhereClause+='and (MedicationName LIKE ''%'+ @Keyword +'%'' or MedicationClass LIKE ''%'+ @Keyword +'%'' or MedicationCode LIKE ''%'+ @Keyword +'%'' or Manufacturer LIKE ''%'+ @Keyword +'%'' or Type LIKE ''%'+ @Keyword +'%''or Dosage LIKE ''%'+ @Keyword +'%'' or Usage LIKE ''%'+ @Keyword +'%'')'
	END

  IF (@UserGuid is not null)
	BEGIN 
	SET @WhereClause+=' AND (CreatedByUserId LIKE ''%'+ @UserId +'%'')'
	END

  IF(@OrderBy='Medication name ' )
  BEGIN
  SET @OrderByClause+=' order by MedicationName '+ @SortType
  SET @FinalOrderBy +=' order by MedicationName '+ @SortType
  END

  IF(@OrderBy='Medication class  ' )
  BEGIN
  SET @OrderByClause+=' order by MedicationClass  '+ @SortType
  SET @FinalOrderBy +=' order by MedicationClass  '+ @SortType
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
	                          [Lookup].[Medications] lm WITH(NOLOCK,READUNCOMMITTED)
							    LEFT JOIN
								[dbo].[Users] du WITH(NOLOCK,READUNCOMMITTED)
								ON du.UserId=lm.CreatedByUserId AND du.IsDeleted=0 
                               WHERE 
							    lm.IsDeleted=0 '
							 + @WhereClause+ ' ) as TotalCount '

SET @AdditionalQuery+=' from tblMedications tms'
 
  SET @Query+= @SQL + @WhereClause  + @OrderByClause + @OffsetClause+ ')' + @AdditionalQuery + @FinalOrderBy
	
  PRINT @Query

EXECUTE sp_executesql @Query

SET NOCOUNT OFF
END
GO


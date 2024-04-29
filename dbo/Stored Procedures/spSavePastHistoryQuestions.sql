
CREATE PROCEDURE [dbo].[spSavePastHistoryQuestions] 
     @QuestionGuid uniqueIdentifier=null
    ,@PastHistoryTypeGuid uniqueIdentifier=null
    ,@FieldName VARCHAR(50)
    ,@FieldTypeGuid VARCHAR(50)
    ,@RowOrder INT
    ,@Units varchar(50)=null
    ,@Option1 varchar(1000)=null
	,@Option2 varchar(1000)=null
	,@Option3 varchar(1000)=null
	,@Option4 varchar(1000)=null
	,@Option5 varchar(1000)= null
	,@Option6 varchar(1000)=null
	,@Option7 varchar(1000)=null
	,@Option8 varchar(1000)=null
	,@Option9 varchar(1000)=null
	,@Option10 varchar(1000)= null
    ,@SqlQuery varchar(MAX)=null

 AS

/*

 MODIFICATIONS

select * from [Lookup].[PastHistoryType]
select * from [PastHistoryType].[Fields]
select * from [Lookup].[PastHistoryQuestionType]

 exec [dbo].[spSavePastHistoryQuestions] 
             @QuestionGuid=null
			,@PastHistoryTypeGuid='31AB9538-0917-4FEE-87A5-F3EF7024C7AD'
			,@FieldName='Do You have Diabetes?'
			,@FieldTypeGuid='C1967935-4AAC-45FC-87C5-2B7A3C11B68D'
			,@RowOrder=1
			,@Units=null
			,@Option1='Yes'
			,@Option2='No'
			,@Option3=null
			,@Option4=null
			,@Option5= null
			,@Option6=null
			,@Option7=null
			,@Option8=null
			,@Option9=null
			,@Option10= null
			,@SqlQuery=null
			
 Date					Author				Description          
 -----------------------------------------------------------------------------
 07/04/2023			M Chandrani	          Add questions of patient history
 ------------------------------------------------------------------------------      
                Copyright 2023@YodaLIMS
*/ 

BEGIN
SET NOCOUNT ON

/*Declaration */

DECLARE @PastHistoryTypeId INT 
SELECT @PastHistoryTypeId=id from [Lookup].[PastHistoryType] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and Guid=@PastHistoryTypeGuid

DECLARE @FieldType varchar(200) 
SELECT @FieldType=QuestionType from [Lookup].[PastHistoryQuestionType]  WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and Guid=@FieldTypeGuid
print(@FieldType)

DECLARE @Id INT
SELECT @Id=id from [PastHistoryType].[Fields] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and Guid=@QuestionGuid

DECLARE @PastHistoryFieldName Varchar(max)
SELECT @PastHistoryFieldName= PastHistoryFieldName From [Lookup].[PastHistoryType]  WITH(NOLOCK,READUNCOMMITTED) WHERE Guid=@FieldTypeGuid



/*Main Query */

  MERGE [PastHistoryType].[Fields] AS trg 
  Using(
        select
             @Id as Id
			,@PastHistoryTypeId as PastHistoryTypeId
			,@FieldName as FieldName
			,@FieldType as FieldType
			,@RowOrder as RowOrder
			,@Units as Units
			,@Option1 as Option1 
			,@Option2 as Option2
			,@Option3 as Option3
			,@Option4 as Option4 
			,@Option5 as Option5 
			,@Option6 as Option6
			,@Option7 as Option7
			,@Option8 as Option8
			,@Option9 as Option9 
			,@Option10 as Option10
			,@SqlQuery as SqlQuery
           
		  ) as src
		  ON  
		    trg.Id =@Id 

	WHEN MATCHED THEN
		 UPDATE 
		   SET		    
             FieldName=src.FieldName
			,FieldType=src.FieldType
			,RowOrder=src.RowOrder
			,Units=src.Units
			,Option1=src.Option1 
			,Option2=src.Option2
			,Option3=src.Option3
			,Option4=src.Option4 
			,Option5=src.Option5 
			,Option6=src.Option6
			,Option7=src.Option7
			,Option8=src.Option8
			,Option9=src.Option9 
			,Option10=src.Option10
			,SqlQuery=src.SqlQuery

	 WHEN NOT MATCHED THEN
		insert(
		     PastHistoryTypeId
		    ,FieldName
			,FieldType
			,RowOrder
			,Units
			,Option1
			,Option2
			,Option3
			,Option4
			,Option5 
			,Option6
			,Option7
			,Option8
			,Option9
			,Option10
			,SqlQuery
		  )
		   values( 
		     @PastHistoryTypeId
		    ,@FieldName
			,@FieldType
			,@RowOrder
			,@Units
			,@Option1
			,@Option2
			,@Option3
			,@Option4
			,@Option5 
			,@Option6
			,@Option7
			,@Option8
			,@Option9
			,@Option10
			,@SqlQuery
		);

SET NOCOUNT OFF
END




  




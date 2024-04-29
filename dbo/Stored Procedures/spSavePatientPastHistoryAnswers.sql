CREATE PROCEDURE [dbo].[spSavePatientPastHistoryAnswers]       
	 @AppointmentGuid uniqueIdentifier=null
	,@PastHistoryAnswersUDT [dbo].[PastHistoryAnswersUDT] READONLY

 AS

/*

 MODIFICATIONS

select * from [Lookup].[PastHistoryType]
select * from [PastHistoryType].[Fields]
select * from  [mapping].[PatientPastHistory] order by 1 desc

DECLARE @PastHistoryAnswersUDT [dbo].[PastHistoryAnswersUDT]
insert into @PastHistoryAnswersUDT  values('94e3d488-9784-4979-94d7-2c4a60d3246e','no')

exec [dbo].[spSavePatientPastHistoryAnswers] 
			 @AppointmentGuid='14198a07-f25e-48e7-8f36-60bbdf846178'
			,@PastHistoryAnswersUDT=@PastHistoryAnswersUDT
			
 Date					Author				Description          
 -----------------------------------------------------------------------------
 07/04/2023			M Chandrani	          Add questions of patient history
 ------------------------------------------------------------------------------      
                Copyright 2023@YodaLIMS
*/ 

BEGIN
SET NOCOUNT ON

/*Declaration */

DECLARE @AppointmentId INT,@PatientId INT 
SELECT @AppointmentId=id,@PatientId=PatientId from [Patient].[Appointment] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and guid=@AppointmentGuid

DECLARE @PastHistoryAnswers TABLE(QuestionTypeGuid uniqueidentifier,Answer varchar(max))
        insert into @PastHistoryAnswers
		SELECT  
             lpf.Guid as QuestionTypeGuid,
			 pudt.Answer
        FROM	          
	        [PastHistoryType].[fields] lpf WITH(NOLOCK,READUNCOMMITTED)
			 inner join @PastHistoryAnswersUDT pudt
	         on 
	         lpf.Guid=pudt.QuestionTypeGuid
        WHERE 
	       lpf.IsDeleted=0 

/*Main Query */

MERGE [mapping].[PatientPastHistory] AS trg 
USING (
    SELECT
        @AppointmentId AS AppointmentId,
        @PatientId AS PatientId,
        q.Id AS QuestionId,
        a.Answer
    FROM @PastHistoryAnswers AS a
    INNER JOIN [PastHistoryType].[fields] AS q 
	ON a.QuestionTypeGuid = q.Guid
) AS src 
ON (trg.AppointmentId = src.AppointmentId AND trg.QuestionId = src.QuestionId) AND trg.IsDeleted=0
WHEN MATCHED THEN
    UPDATE 
    SET		    
        Answer = src.Answer
WHEN NOT MATCHED THEN
    INSERT (
        AppointmentId,
        PatientId,
        QuestionId,
        Answer
    )
    VALUES (
        src.AppointmentId,
        src.PatientId,
        src.QuestionId,
        src.Answer
    );

SET NOCOUNT OFF
END
GO


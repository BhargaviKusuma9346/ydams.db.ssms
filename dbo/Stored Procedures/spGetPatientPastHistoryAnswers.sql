CREATE procedure [dbo].[spGetPatientPastHistoryAnswers]   
       @AppointmentGuid uniqueIdentifier
AS        
      
/*
 exec [dbo].[spGetPatientPastHistoryAnswers]   @AppointmentGuid='4B59F148-6726-440D-84B3-B593B41AC972'
 -------------------------------------------------------------              

 MODIFICATIONS 
 
 Date					Author				Description          
 -----------------------------------------------------------------------------
20/04/2023			   M.Chandrani	           to get Patient Past History Answers
 ------------------------------------------------------------------------------      
                Copyright 2023@YLIMS
*/        
BEGIN 

SET NOCOUNT ON

/*Declaration */

SELECT 	     
             pa.Guid as AppointmentGuid,
	         pp.Guid as PatientGuid, 
			 lp.Guid as PastHistoryTypeGuid,
			 lp.PastHistoryFieldName as PastHistoryType,			
			 pf.FieldName as Question,
			 pf.Guid as QuestionGuid,
			 lpq.Guid as QuestionTypeGuid,	
			 pf.FieldType as QuestionType,
			 pf.Option1,
			 pf.Option2,
			 pf.Option3,
			 pf.Option4,
			 pf.Option5,
			 pf.Option6,
			 pf.Option7,
			 pf.Option8,
			 pf.Option9,
			 pf.Option10,
			 mpp.Answer
	FROM
	    [mapping].[PatientPastHistory] mpp WITH(NOLOCK,READUNCOMMITTED)
		INNER JOIN
		[Patient].[Patient] pp WITH(NOLOCK,READUNCOMMITTED)
		ON mpp.PatientId=pp.Id
		INNER JOIN
		[Patient].[Appointment] pa WITH(NOLOCK,READUNCOMMITTED)
		ON pa.Id=mpp.AppointmentId
		INNER JOIN
		[PastHistoryType].[Fields] pf WITH(NOLOCK,READUNCOMMITTED)
		ON pf.Id=mpp.QuestionId
		INNER JOIN
		[Lookup].[PastHistoryQuestionType]  lpq WITH(NOLOCK,READUNCOMMITTED)
		ON pf.FieldType=lpq.QuestionType
		INNER JOIN
		[Lookup].[PastHistoryType] lp WITH(NOLOCK,READUNCOMMITTED)
		ON pf.PastHistoryTypeId=lp.Id
	WHERE
	    pa.Guid=@AppointmentGuid and mpp.IsDeleted=0

		
SET NOCOUNT OFF

END
GO


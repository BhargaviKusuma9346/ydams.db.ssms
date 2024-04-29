CREATE procedure [Patient].[spDeletePastHistoryAnwser] 
  @AppointmentGuid uniqueIdentifier,
  @QuetionGuid uniqueIdentifier
  
AS        
      
/*
 exec [Patient].[spDeletePastHistoryAnwser]   @PatientGuid='669689A3-8F69-4111-9069-F5FD101ACF7F',@UserGuid='AEA80B99-1D3A-4CBE-AC61-1563630BF7B5'
 -------------------------------------------------------------              
    select * from [Lookup].[PastHistoryType]
select * from [PastHistoryType].[Fields]
select * from  [mapping].[PatientPastHistory] order by 1 desc

 MODIFICATIONS        
 Date					Author				Description          
 -----------------------------------------------------------------------------
13/10/2023			   Ch.Karthik	           to Delete Past History Anwser
 ------------------------------------------------------------------------------      
                Copyright 2023@YLIMS
*/        
BEGIN 

SET NOCOUNT ON
declare @AppointmentId int
declare @PatientId int
declare @QuetionId int


SELECT @AppointmentId=id,@PatientId=PatientId from [Patient].[Appointment] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and guid=@AppointmentGuid
SELECT @QuetionId=id from [PastHistoryType].[fields] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and guid=@QuetionGuid

UPDATE [mapping].[PatientPastHistory]
SET IsDeleted = 1
WHERE 
@AppointmentId=@AppointmentId 
and 
PatientId=@PatientId 
and 
QuestionId=@QuetionId;
SET NOCOUNT OFF
END
GO


CREATE TYPE [Doctor].[DoctorAvailabilitySlotsUDT] AS TABLE (
    [DoctorAvailabilitySlotGuid] UNIQUEIDENTIFIER NULL,
    [WeekDayId]                  INT              NULL,
    [SlotName]                   VARCHAR (200)    NULL,
    [StartTime]                  TIME (7)         NULL,
    [EndTime]                    TIME (7)         NULL,
    [NumberOfSlots]              INT              NULL,
    [IsDeleted]                  BIT              NULL);


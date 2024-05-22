-- Get distinct event types from the CommEvents table
select distinct(eventtype) from [CommEvents(2-28-20)]

-- Get the top 1000 durations from the CommEvents table
select top 1000 duration from [CommEvents(2-28-20)]

-- Create a new table named EventSeries with columns for timestamp, sender, receiver, and time difference
CREATE TABLE EventSeries (
                             timestamp DATETIME,
                             sender INT,
                             receiver INT,
                             time_difference INT
);

-- Add a new column named duration to the EventSeries table
alter table EventSeries add  duration float

-- Insert data into the EventSeries table from the CommEvents table for 'Call' events
INSERT INTO EventSeries (timestamp, sender, receiver, time_difference, duration)
SELECT
    timestamp,
    egoid,
    alterid,
    DATEDIFF(DAY, MIN(timestamp) OVER (PARTITION BY egoid), timestamp) AS time_difference,
    duration
FROM
    [CommEvents(2-28-20)]
where eventtype = 'Call'

-- Create a new table named CallEvents with columns for timestamp, egoid, alterid, time_difference, duration, and outgoing
create TABLE CallEvents (
                            timestamp DATETIME,
                            egoid INT,
                            alterid INT,
                            time_difference INT,
                            duration FLOAT,
                            outgoing VARCHAR(50)
)

-- Insert data into the CallEvents table from the CommEvents table for 'Call' events
INSERT INTO CallEvents (egoid, alterid, timestamp, duration, time_difference, outgoing)
SELECT
    egoid,
    alterid,
    timestamp,
    duration,
    DATEDIFF(DAY, MIN(timestamp) OVER (PARTITION BY egoid, alterid), timestamp) AS time_difference,
    outgoing
FROM
    [CommEvents(2-28-20)]
WHERE
        eventtype = 'Call';

-- Create a new table named SMSEvents with columns for timestamp, egoid, alterid, time_difference, length, bytes, and outgoing
create TABLE SMSEvents (
                           timestamp DATETIME,
                           egoid INT,
                           alterid INT,
                           time_difference INT,
                           length FLOAT,
                           bytes INT,
                           outgoing VARCHAR(50)
)

-- Insert data into the SMSEvents table from the CommEvents table for 'SMS', 'MMS', and 'WhatsApp' events
INSERT INTO SMSEvents (egoid, alterid, timestamp, length, time_difference, outgoing, bytes)
SELECT
    egoid,
    alterid,
    timestamp,
    length,
    DATEDIFF(DAY, MIN(timestamp) OVER (PARTITION BY egoid, alterid), timestamp) AS time_difference,
    outgoing,
    bytes
FROM
    [CommEvents(2-28-20)]
WHERE
        eventtype in ('SMS', 'MMS', 'WhatsApp');

-- Add a new column named tuple to the CallEvents table
alter table CallEvents add tuple varchar(200)

-- Update the tuple column in the CallEvents table with a combination of the egoid and alterid columns
UPDATE CallEvents
SET tuple = CONCAT('(', egoid, ', ', alterid, ')');

-- Insert data into the CallEvents table from the CommEvents table for 'call' events where the alterid is also an egoid in the CallEvents table
INSERT INTO CallEvents (timestamp, egoid, alterid, duration, time_difference, outgoing, tuple)
SELECT timestamp,
       egoid,
       alterid,
       duration,
       DATEDIFF(DAY, MIN(timestamp) OVER (PARTITION BY egoid, alterid), timestamp) AS time_difference,
       outgoing,
       CONCAT('(', egoid, ', ', alterid, ')') AS tuple
FROM [CommEvents(2-28-20)]
WHERE alterid IS NOT NULL AND alterid IN (SELECT egoid FROM CallEvents WHERE egoid IS NOT NULL) AND eventtype = 'call';
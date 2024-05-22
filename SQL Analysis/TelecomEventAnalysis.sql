-- This query is used to get the total number of communication events, call events, message events (SMS, MMS, Whatsapp), and total call duration for each egoid.
SELECT
    egoid,
    COUNT(*) AS communication_events,
    SUM(CASE WHEN eventtype = 'call' THEN 1 ELSE 0 END) AS call_events,
    SUM(CASE WHEN eventtype IN ('SMS', 'MMS', 'whatsapp') THEN 1 ELSE 0 END) AS message_events,
    SUM(CASE WHEN eventtype = 'call' THEN TRY_CAST(duration AS FLOAT) ELSE 0 END) AS total_call_duration
FROM
    telecomDB.dbo.[CommEvents(2-28-20)]  -- Replace with the actual name of your table
GROUP BY
    egoid
ORDER BY
    communication_events DESC;

-- This query is used to get the number of call events for each egoid for each hour of the day.
SELECT
    egoid,
    DATEPART(HOUR, [time]) AS hour_of_day,
    COUNT(*) AS call_count
FROM
    telecomDB.dbo.[CommEvents(2-28-20)]
WHERE
        eventtype = 'call'
GROUP BY
    egoid,
    DATEPART(HOUR, [time])
ORDER BY
    egoid,
    hour_of_day;

-- This query is used to get the inter-event time (time between two consecutive call events) for each egoid and the cumulative count and distribution of these inter-event times.
WITH InterEventTimes AS (
    SELECT
        egoid,
        LAG([time]) OVER (PARTITION BY egoid ORDER BY [time]) AS prev_time,
        [time] AS cur_time,
        DATEDIFF(HOUR, LAG([time]) OVER (PARTITION BY egoid ORDER BY [time]), [time]) AS inter_event_time
    FROM
        telecomDB.dbo.[CommEvents(2-28-20)]
    WHERE
        eventtype = 'call'
)
SELECT
    egoid,
    inter_event_time,
    COUNT(*) AS cumulative_count,
    CAST(SUM(COUNT(*)) OVER (PARTITION BY egoid ORDER BY inter_event_time) AS FLOAT) / COUNT(*) AS cumulative_distribution
FROM
    InterEventTimes
GROUP BY
    egoid,
    inter_event_time
ORDER BY
    egoid,
    inter_event_time;

-- This query is used to get the inter-event time (time between two consecutive call events) and the empirical complementary cumulative distribution function (CCDF) of these inter-event times.
WITH InterEventTimes AS (
    SELECT
        LAG([time]) OVER (ORDER BY [time]) AS prev_time,
        [time] AS cur_time,
        DATEDIFF(HOUR, LAG([time]) OVER (ORDER BY [time]), [time]) AS inter_event_time
    FROM
        telecomDB.dbo.[CommEvents(2-28-20)]
    WHERE
        eventtype = 'call'
)
   , InterEventCounts AS (
    SELECT
        inter_event_time,
        COUNT(*) AS event_count
    FROM
        InterEventTimes
    GROUP BY
        inter_event_time
)
SELECT
    inter_event_time,
    1.0 - (CAST(SUM(event_count) OVER (ORDER BY inter_event_time) AS FLOAT) / SUM(event_count) OVER ()) AS empirical_ccdf
FROM
    InterEventCounts
ORDER BY
    inter_event_time;

-- This query is similar to the previous one, but it calculates the empirical CCDF for all types of events, not just call events.
WITH InterEventTimes AS (
    SELECT
        LAG([time]) OVER (ORDER BY [time]) AS prev_time,
        [time] AS cur_time,
        DATEDIFF(HOUR, LAG([time]) OVER (ORDER BY [time]), [time]) AS inter_event_time
    FROM
        telecomDB.dbo.[CommEvents(2-28-20)]
)
   , InterEventCounts AS (
    SELECT
        inter_event_time,
        COUNT(*) AS event_count
    FROM
        InterEventTimes
    GROUP BY
        inter_event_time
)
   , CDFData AS (
    SELECT
        inter_event_time,
        SUM(event_count) OVER (ORDER BY inter_event_time) AS cumulative_count
    FROM
        InterEventCounts
)
SELECT
    inter_event_time,
    1.0 - (cumulative_count * 1.0 / MAX(cumulative_count) OVER ()) AS empirical_ccdf
FROM
    CDFData
ORDER BY
    inter_event_time;
SELECT
    egoid,
    COUNT(*) AS communication_events,
    SUM(CASE WHEN eventtype = 'call' THEN 1 ELSE 0 END) AS call_events,
    SUM(CASE WHEN eventtype IN ('SMS', 'MMS', 'whatsapp') THEN 1 ELSE 0 END) AS message_events,
    SUM(CASE WHEN eventtype = 'call' THEN TRY_CAST(duration AS FLOAT) ELSE 0 END) AS total_call_duration
FROM
    telecomDB.dbo.[CommEvents(2-28-20)]
GROUP BY
    egoid
ORDER BY
    communication_events DESC;

SELECT
    egoid,
    DATEPART(HOUR, [time]) AS hour_of_day,
    COUNT(*) AS call_count
FROM
    telecomDB.dbo.[CommEvents(2-28-20)]
WHERE
        eventtype = 'call'
GROUP BY
    egoid,
    DATEPART(HOUR, [time])
ORDER BY
    egoid,
    hour_of_day;


WITH InterEventTimes AS (
    SELECT
        egoid,
        LAG([time]) OVER (PARTITION BY egoid ORDER BY [time]) AS prev_time,
        [time] AS cur_time,
        DATEDIFF(HOUR, LAG([time]) OVER (PARTITION BY egoid ORDER BY [time]), [time]) AS inter_event_time
    FROM
        telecomDB.dbo.[CommEvents(2-28-20)]
    WHERE
        eventtype = 'call'
)
SELECT
    egoid,
    inter_event_time,
    COUNT(*) AS cumulative_count,
    CAST(SUM(COUNT(*)) OVER (PARTITION BY egoid ORDER BY inter_event_time) AS FLOAT) / COUNT(*) AS cumulative_distribution
FROM
    InterEventTimes
GROUP BY
    egoid,
    inter_event_time
ORDER BY
    egoid,
    inter_event_time;



WITH InterEventTimes AS (
    SELECT
        LAG([time]) OVER (ORDER BY [time]) AS prev_time,
        [time] AS cur_time,
        DATEDIFF(HOUR, LAG([time]) OVER (ORDER BY [time]), [time]) AS inter_event_time
    FROM
        telecomDB.dbo.[CommEvents(2-28-20)]
    WHERE
        eventtype = 'call'
)
   , InterEventCounts AS (
    SELECT
        inter_event_time,
        COUNT(*) AS event_count
    FROM
        InterEventTimes
    GROUP BY
        inter_event_time
)
SELECT
    inter_event_time,
    1.0 - (CAST(SUM(event_count) OVER (ORDER BY inter_event_time) AS FLOAT) / SUM(event_count) OVER ()) AS empirical_ccdf
FROM
    InterEventCounts
ORDER BY
    inter_event_time;


WITH InterEventTimes AS (
    SELECT
        LAG([time]) OVER (ORDER BY [time]) AS prev_time,
        [time] AS cur_time,
        DATEDIFF(HOUR, LAG([time]) OVER (ORDER BY [time]), [time]) AS inter_event_time
    FROM
        telecomDB.dbo.[CommEvents(2-28-20)]
)
   , InterEventCounts AS (
    SELECT
        inter_event_time,
        COUNT(*) AS event_count
    FROM
        InterEventTimes
    GROUP BY
        inter_event_time
)
   , CDFData AS (
    SELECT
        inter_event_time,
        SUM(event_count) OVER (ORDER BY inter_event_time) AS cumulative_count
    FROM
        InterEventCounts
)
SELECT
    inter_event_time,
    1.0 - (cumulative_count * 1.0 / MAX(cumulative_count) OVER ()) AS empirical_ccdf
FROM
    CDFData
ORDER BY
    inter_event_time;







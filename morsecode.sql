.mode csv
.import ./amplitude.out raw

CREATE TABLE IF NOT EXISTS "message"(
  "sample" INTEGER PRIMARY KEY AUTOINCREMENT,
  "amplitude" DECIMAL
);

/* Filter amplitudes and make them absolute. Simplifies detecting "peaks" or rather the begininning of a audible signal  */
create view filtered_absolute_amplitudes as 
SELECT avg(ABS(CAST(amplitude AS DECIMAL))) over (ROWS BETWEEN 1 PRECEDING AND 500 FOLLOWING) as amplitude 
FROM raw;

/* Normalize the amplitudes to a table together with its "index", or to be more precise, sample */
INSERT INTO message(amplitude)
SELECT 1.00*(amplitude-amplitude_min)/amplitude_range AS amplitude
FROM
  (SELECT ABS(CAST(amplitude AS DECIMAL)) AS amplitude,
          MIN(ABS(CAST(amplitude AS DECIMAL))) OVER () AS amplitude_min,
          MAX(ABS(CAST(amplitude AS DECIMAL))) OVER () - MIN(ABS(CAST(amplitude AS DECIMAL))) OVER () AS amplitude_range
   FROM filtered_absolute_amplitudes);

/* Starting and ending points (samples) of audible signal amplitude */
create view signal as
SELECT sample AS begin_sample,
  (SELECT sample
   FROM message
   /* Magic number 0.3 to identify an audible signal */
   WHERE amplitude < 0.3
     AND sample > a.sample
   LIMIT 1) AS end_sample,
  'N' AS TYPE
FROM message AS a
WHERE amplitude > 0.3;

/* Starting and ending points (samples) of silence */
create view silence as
SELECT sample AS begin_sample,
  (SELECT sample
   FROM message
   WHERE amplitude > 0.3
     AND sample > a.sample
   LIMIT 1) AS end_sample,
       'S' AS TYPE
FROM message AS a
WHERE amplitude < 0.3;


SELECT group_concat(codepoint, '')
FROM
  (SELECT CASE
             /* Magic audible signal length in samples to detect a dot. TODO thresholds should not be hard coded because they dependend on the operators "fist" */
              WHEN end_sample - begin_sample < 9000
                   AND TYPE = 'N' THEN '.'
              /* Longer audible singals are dashes */
              WHEN TYPE = 'N' THEN '-'
                /* Long silences are spaces between words */
              WHEN end_sample - begin_sample > 11000
                   AND TYPE = 'S' THEN '/'
             /* Short silences separate letters */
              ELSE ' '
          END AS codepoint
   FROM (select * from signal UNION ALL select * from silence)
   WHERE end_sample IS NOT NULL
     AND (TYPE = 'N'
          OR (end_sample - begin_sample > 3000
              AND TYPE = 'S'))
   GROUP BY end_sample
   LIMIT -1
   OFFSET 1);
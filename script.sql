
WITH GrowthData AS (
  SELECT
    species_scientific_name,
    CAST(RAND() * (10 - 5) + 5 AS INT64) AS sample_average_time,  -- Random average growth time between 5 and 10 years
    CAST(RAND() * (3 - 1) + 1 AS INT64) AS pop_stddev_time,  -- Random standard deviation between 1 and 3 years
  FROM
    `bigquery-public-data.new_york_trees.tree_species`
),
GrowthDataMicros AS (
  SELECT
    species_scientific_name,
    UNIX_MICROS(TIMESTAMP_SECONDS(sample_average_time * 31536000)) AS sample_average,  -- Convert years to microseconds
    UNIX_MICROS(TIMESTAMP_SECONDS(pop_stddev_time * 31536000)) AS pop_stddev
  FROM
    GrowthData
),
SpeciesCount AS (
  SELECT
    COUNT(*) as species_count -- Assume this is the number of samples
  FROM
    `bigquery-public-data.new_york_trees.tree_species`
),
ConfidenceIntervals AS (
  SELECT
    gdm.species_scientific_name,
    gdm.sample_average,
    gdm.sample_average + (1.96 * gdm.pop_stddev / SQRT(sc.species_count)) AS upper_bound,
    gdm.sample_average - (1.96 * gdm.pop_stddev / SQRT(sc.species_count)) AS lower_bound
  FROM
    GrowthDataMicros gdm, SpeciesCount sc
)
SELECT
  species_scientific_name,
  sample_average,
  upper_bound,
  lower_bound
FROM
  ConfidenceIntervals;
  

# Agriculture Schema Migration Guide

## Phase 1: Schema Normalization (COMPLETED)

This phase normalizes the agriculture schema following SQL Project best practices with idempotent operations.

### Changes Made

#### 1. Enhanced Crops Table (`Crops.sql`)
- ✅ Added idempotent CREATE TABLE checks
- ✅ Added `WaterRequirementMmPerWeek SMALLINT` (numeric water requirement 10-120 mm/week)
- ✅ Enhanced constraints for data integrity:
  - `CK_Crops_OptimalRanges`: Ensures min < max for temperature and humidity
  - `CK_Crops_StressRanges`: Ensures stress ranges encompass optimal ranges
  - `CK_Crops_WaterRequirement`: Validates numeric water requirement (10-120)
- ✅ Added performance indexes:
  - `IX_Crops_Code`: Fast lookup by crop code
  - `IX_Crops_Active`: Filter active crops

#### 2. New CropSeasons Table (`CropSeasons.sql`)
- ✅ Replaces JSON month arrays with normalized structure
- ✅ Columns: `CropID`, `Month` (1-12), `SeasonType` ('P'/'H'), `Priority`, `Notes`
- ✅ Foreign key to Crops with CASCADE DELETE
- ✅ Performance indexes for common queries

#### 3. Enhanced CityCrops Table (`CityCrops.sql`) 
- ✅ Added idempotent CREATE TABLE checks
- ✅ Enhanced constraints for local adjustments
- ✅ Added audit fields (`CreatedDate`, `UpdatedDate`)
- ✅ CASCADE DELETE foreign keys
- ✅ City metadata indexes for agricultural queries

#### 4. Backfill Procedure (`usp_BackfillCropSeasons.sql`)
- ✅ Migrates JSON arrays to normalized CropSeasons table
- ✅ Uses OPENJSON to parse legacy data
- ✅ Idempotent - won't create duplicates
- ✅ Updates numeric water requirements from text values
- ✅ Error handling and progress reporting

#### 5. Helper Views (`agriculture_views.sql`)
- ✅ `vw_CropSeasons`: Crops with normalized seasons and JSON compatibility
- ✅ `vw_CityCropSuitability`: Enhanced city-crop relationships with local adjustments

#### 6. Updated Post-Deployment Script
- ✅ Executes backfill procedure automatically
- ✅ Migrates existing data to new structure

### Deployment Order

The files should be deployed in this order (handled automatically by SQL Project):

1. `agriculture_schema.sql` - Schema creation
2. `Crops.sql` - Enhanced crops table
3. `CropSeasons.sql` - Normalized seasons table  
4. `CityCrops.sql` - Enhanced city-crops relationships
5. `usp_BackfillCropSeasons.sql` - Migration procedure
6. `agriculture_views.sql` - Helper views
7. `Script.PostDeployment.sql` - Data migration execution

### Benefits Achieved

- **Data Integrity**: Strong constraints prevent invalid data
- **Performance**: Optimized indexes for common queries
- **Normalization**: Replaced JSON with proper relational structure
- **Maintainability**: Idempotent scripts support repeatable deployments
- **Compatibility**: Views maintain API compatibility during transition

## Phase 2: Legacy Column Removal (FUTURE)

⚠️ **DO NOT EXECUTE UNTIL API/UI MIGRATION IS COMPLETE**

After all consumers are updated to use the normalized CropSeasons table:

```sql
-- Remove legacy JSON columns (only after API migration)
ALTER TABLE agriculture.Crops DROP COLUMN PlantingMonths;
ALTER TABLE agriculture.Crops DROP COLUMN HarvestMonths;

-- Remove legacy text water requirement (keep numeric only)
ALTER TABLE agriculture.Crops DROP COLUMN WaterRequirement;
```

### Testing Queries

Verify the migration worked correctly:

```sql
-- Check crops have seasons data
SELECT c.CropCode, c.CropNameSpanish,
       COUNT(CASE WHEN cs.SeasonType = 'P' THEN 1 END) as PlantingMonths,
       COUNT(CASE WHEN cs.SeasonType = 'H' THEN 1 END) as HarvestMonths
FROM agriculture.Crops c
LEFT JOIN agriculture.CropSeasons cs ON c.CropID = cs.CropID
GROUP BY c.CropID, c.CropCode, c.CropNameSpanish;

-- Check water requirements were migrated
SELECT CropCode, WaterRequirement, WaterRequirementMmPerWeek 
FROM agriculture.Crops;

-- Test the views
SELECT * FROM agriculture.vw_CropSeasons WHERE CropCode = 'CAFE';
SELECT * FROM agriculture.vw_CityCropSuitability WHERE CityCode = 'GUA';
```

### Rollback Plan

If issues occur, the migration is reversible:

1. The original JSON columns are preserved
2. New tables can be dropped: `DROP TABLE agriculture.CropSeasons`  
3. New columns can be removed: `ALTER TABLE agriculture.Crops DROP COLUMN WaterRequirementMmPerWeek`
4. Constraints can be dropped by name

This completes Phase 1 of the agriculture schema normalization with full SQL Project compatibility.

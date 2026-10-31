 /*

DATABASE LAYERS:

Bronze - Stores raw data loaded from source CSV files.

Silver - Stores cleaned, standardized, and transformed data.

Gold   - Stores business-ready data for reporting and analytics.

DESIGN NOTES:

CREATE DATABASE IF NOT EXISTS prevents errors if a database already exists.

Existing databases and their tables are not deleted by these statements.

This script creates databases only; it does not create tables or load data.

===============================================================================
*/
 
 
 -- Creating 3 Database 
 
 -- 1st
 
-- Create databases only if they don't exist
 CREATE DATABASE IF NOT EXISTS bronze;
 -- 2nd

-- Create databases only if they don't exist
 CREATE DATABASE IF NOT EXISTS silver;
 -- 3rd

 -- Create databases only if they don't exist
   CREATE DATABASE IF NOT EXISTS gold;
 
 




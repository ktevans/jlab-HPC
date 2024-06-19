## Usage Instructions

1. **Update `directories.txt`**:
   - Include full paths to directories containing files that need preservation, one path per line.
   - Example:
     ```
     /full/path/to/volatile/directory1
     /full/path/to/volatile/directory1/subdirectory
     /full/path/to/volatile/directory2
     ```

2. **Set Script Permissions**:
   - Make `touch_files.sh` executable:
     ```
     chmod u+x touch_files.sh
     ```

3. **Configure Crontab**:
3. **Configure Crontab**:
   - To schedule the script for automatic execution, first open the crontab file with:
     ```
     crontab -e
     ```
   - Then, add a line to run `touch_files.sh` once a week on Sunday at midnight:
     ```
     0 0 * * 0 /path/to/touch_files.sh
     ```
   - Ensure you replace `/path/to/touch_files.sh` with the actual path to your script. This step schedules the script in your crontab for regular execution.
   - Adjust the crontab entry according to your scheduling needs.

This setup ensures your files remain accessible by periodically updating their timestamps, circumventing the auto-deletion policy of /volatile storage.
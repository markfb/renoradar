# 008 - Property Scraping Agent Tasks

## Phase 1: Database Setup

### 1.1 Migrations
- [ ] Create `database/migrations/029_create_scraped_properties_table.php`
- [ ] Create `database/migrations/030_create_scrape_jobs_table.php`
- [ ] Run migrations

## Phase 2: Agent Prompt

### 2.1 Prompt File
- [ ] Create `prompts/` directory
- [ ] Create `prompts/property-scraper.txt` with optimised prompt
- [ ] Test prompt with sample HTML inputs
- [ ] Refine based on output quality

## Phase 3: Core Services

### 3.1 Claude API Integration
- [ ] Implement `src/Services/ClaudeApiService.php`
  - [ ] API authentication
  - [ ] Request/response handling
  - [ ] JSON response parsing
  - [ ] Error handling and retries
  - [ ] Rate limiting

### 3.2 HTML Fetcher
- [ ] Implement `src/Services/HtmlFetcherService.php`
  - [ ] URL validation
  - [ ] HTTP request with appropriate headers
  - [ ] User-agent handling
  - [ ] Redirect following
  - [ ] Timeout handling

### 3.3 Scraping Agent Service
- [ ] Implement `src/Services/ScrapingAgentService.php`
  - [ ] scrapeFromHtml()
  - [ ] scrapeFromUrl()
  - [ ] processBatch()
  - [ ] approveAndImport()
  - [ ] Validation integration

### 3.4 Property Import Service
- [ ] Implement `src/Services/PropertyImportService.php`
  - [ ] import() - Create property from scraped data
  - [ ] generateSlug()
  - [ ] generateTitle()
  - [ ] importImages() - Download and store images
  - [ ] addFeatures() - Create features from analysis
  - [ ] Postcode normalisation

## Phase 4: Models & Validators

### 4.1 Models [P]
- [ ] Implement `src/Models/ScrapedProperty.php`
  - Column mappings
  - JSON casting for extracted_data, renovation_analysis
  - Status management
  - Relationships

- [ ] Implement `src/Models/ScrapeJob.php`
  - Column mappings
  - Status management
  - Progress tracking
  - Error log handling

### 4.2 Validator
- [ ] Implement `src/Validators/ScrapedPropertyValidator.php`
  - Required field validation
  - Postcode format validation
  - Price validation
  - Enum validation for property_type, status
  - Renovation analysis structure validation

## Phase 5: Controllers

### 5.1 Admin Scraping Controller
- [ ] Implement `src/Controllers/Admin/ScrapingController.php`
  - [ ] index() - Dashboard with stats
  - [ ] upload() - Upload form
  - [ ] analyse() - Single HTML analysis (AJAX)
  - [ ] batch() - Batch upload handler
  - [ ] jobStatus() - Job progress (AJAX)
  - [ ] review() - Review queue
  - [ ] reviewItem() - Single item review
  - [ ] approve() - Approve and import
  - [ ] reject() - Reject with reason
  - [ ] edit() - Edit extracted data

## Phase 6: Templates

### 6.1 Admin Scraping Pages [P]
- [ ] Create `templates/admin/scraping/index.php`
  - Scraping dashboard
  - Recent jobs
  - Pending review count
  - Quick actions

- [ ] Create `templates/admin/scraping/upload.php`
  - HTML paste textarea
  - URL input option
  - Bulk file upload
  - Submit button

- [ ] Create `templates/admin/scraping/review.php`
  - Pending items list
  - Filter by status, condition
  - Bulk actions

- [ ] Create `templates/admin/scraping/review-item.php`
  - Full extracted data display
  - Renovation analysis details
  - Original HTML preview (sandboxed)
  - Edit form
  - Approve/Reject buttons

- [ ] Create `templates/admin/scraping/batch-status.php`
  - Job progress bar
  - Success/failure counts
  - Error log display
  - Results list

## Phase 7: JavaScript Components

### 7.1 Scraping UI [P]
- [ ] Create `public/assets/js/admin/scraping.js`
  - HTML paste handling
  - AJAX analysis submission
  - Progress polling for batch jobs
  - Review form handling

- [ ] Create `public/assets/js/admin/htmlPreview.js`
  - Sandboxed iframe for HTML preview
  - Security restrictions

## Phase 8: Background Processing

### 8.1 Batch Job Handler
- [ ] Implement `src/Jobs/ProcessScrapeBatchJob.php`
  - Process items sequentially
  - Update job progress
  - Handle failures gracefully
  - Send completion notification

### 8.2 Cron Job
- [ ] Create `cron/process-scrape-jobs.php`
  - Pick up pending batch jobs
  - Process in background

## Phase 9: Configuration

### 9.1 Config Files
- [ ] Create `config/scraping.php`
- [ ] Add environment variables to `.env.example`:
  - ANTHROPIC_API_KEY
  - CLAUDE_MODEL
  - SCRAPING_SYSTEM_USER_ID

## Phase 10: Testing

### 10.1 Unit Tests [P]
- [ ] Test ClaudeApiService
- [ ] Test ScrapingAgentService
- [ ] Test PropertyImportService
- [ ] Test ScrapedPropertyValidator
- [ ] Test postcode normalisation

### 10.2 Integration Tests
- [ ] Test full scrape-to-import flow
- [ ] Test batch processing
- [ ] Test error handling

### 10.3 Agent Quality Tests
- [ ] Test with Rightmove HTML samples
- [ ] Test with Zoopla HTML samples
- [ ] Test with OnTheMarket samples
- [ ] Test with small agent websites
- [ ] Verify renovation classification accuracy

## Phase 11: Sample Data

### 11.1 Test HTML Samples
- [ ] Collect 10+ sample HTML listings
- [ ] Include various property types
- [ ] Include renovation properties
- [ ] Include completed renovation properties
- [ ] Include various listing statuses

## Phase 12: Documentation

### 12.1 Admin Guide
- [ ] Document scraping workflow
- [ ] Document review process
- [ ] Document editing extracted data
- [ ] Document batch processing

### 12.2 Prompt Maintenance
- [ ] Document prompt update process
- [ ] Track prompt version history
- [ ] Document indicator refinements

## Legend
- [P] = Tasks can be executed in parallel

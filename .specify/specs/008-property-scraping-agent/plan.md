# 008 - Property Scraping Agent Technical Plan

## Architecture Overview

The property scraping system uses Claude as the AI extraction engine, wrapped in a PHP service layer that handles input/output, validation, and database integration.

## Directory Structure

```
src/
├── Controllers/
│   └── Admin/
│       └── ScrapingController.php
├── Services/
│   ├── ScrapingAgentService.php
│   ├── HtmlFetcherService.php
│   ├── PropertyImportService.php
│   └── ClaudeApiService.php
├── Models/
│   ├── ScrapedProperty.php
│   └── ScrapeJob.php
├── Validators/
│   └── ScrapedPropertyValidator.php
└── Jobs/
    └── ProcessScrapeBatchJob.php

templates/
└── admin/
    └── scraping/
        ├── index.php
        ├── upload.php
        ├── review.php
        └── batch-status.php
```

## Database Schema

### scraped_properties
```sql
CREATE TABLE scraped_properties (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    scrape_job_id INT UNSIGNED NULL,
    source_url VARCHAR(500) NOT NULL,
    source_name VARCHAR(100) NOT NULL,
    source_html LONGTEXT,
    extracted_data JSON NOT NULL,
    renovation_analysis JSON NOT NULL,

    -- Extracted fields (denormalised for querying)
    property_address VARCHAR(500),
    postcode VARCHAR(10),
    price INT UNSIGNED,
    price_qualifier VARCHAR(20),
    property_type VARCHAR(50),
    bedrooms TINYINT UNSIGNED,
    bathrooms TINYINT UNSIGNED,
    listing_status VARCHAR(20),
    condition_type VARCHAR(30),
    renovation_confidence VARCHAR(10),
    requires_work TINYINT(1),

    -- Processing status
    status ENUM('pending', 'reviewed', 'approved', 'rejected', 'imported') DEFAULT 'pending',
    reviewed_by INT UNSIGNED NULL,
    reviewed_at TIMESTAMP NULL,
    rejection_reason TEXT,
    imported_property_id INT UNSIGNED NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (reviewed_by) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (imported_property_id) REFERENCES properties(id) ON DELETE SET NULL,
    INDEX idx_status (status),
    INDEX idx_postcode (postcode),
    INDEX idx_condition (condition_type),
    INDEX idx_source (source_url(255))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### scrape_jobs
```sql
CREATE TABLE scrape_jobs (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    created_by INT UNSIGNED NOT NULL,
    source_type ENUM('html_paste', 'url_fetch', 'bulk_upload') NOT NULL,
    total_listings INT UNSIGNED DEFAULT 0,
    processed_count INT UNSIGNED DEFAULT 0,
    success_count INT UNSIGNED DEFAULT 0,
    failure_count INT UNSIGNED DEFAULT 0,
    status ENUM('pending', 'processing', 'completed', 'failed') DEFAULT 'pending',
    error_log JSON,
    started_at TIMESTAMP NULL,
    completed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_status (status),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

## Services

### ClaudeApiService

```php
class ClaudeApiService
{
    private string $apiKey;
    private string $model = 'claude-sonnet-4-20250514';
    private string $baseUrl = 'https://api.anthropic.com/v1';

    public function __construct(string $apiKey)
    {
        $this->apiKey = $apiKey;
    }

    public function analysePropertyHtml(string $html, string $sourceUrl): array
    {
        $systemPrompt = $this->getSystemPrompt();
        $userPrompt = $this->buildUserPrompt($html, $sourceUrl);

        $response = $this->sendRequest([
            'model' => $this->model,
            'max_tokens' => 4096,
            'system' => $systemPrompt,
            'messages' => [
                ['role' => 'user', 'content' => $userPrompt]
            ]
        ]);

        return $this->parseJsonResponse($response);
    }

    private function getSystemPrompt(): string
    {
        // Returns the optimised agent prompt from spec
        return file_get_contents(__DIR__ . '/../../prompts/property-scraper.txt');
    }

    private function buildUserPrompt(string $html, string $sourceUrl): string
    {
        return "Analyse this property listing HTML and extract structured data.\n\n" .
               "Source URL: {$sourceUrl}\n\n" .
               "<html>\n{$html}\n</html>";
    }

    private function parseJsonResponse(array $response): array
    {
        $content = $response['content'][0]['text'] ?? '';

        // Clean any markdown code blocks if present
        $content = preg_replace('/^```json\s*/', '', $content);
        $content = preg_replace('/\s*```$/', '', $content);

        $data = json_decode($content, true);

        if (json_last_error() !== JSON_ERROR_NONE) {
            throw new JsonParseException('Failed to parse agent response: ' . json_last_error_msg());
        }

        return $data;
    }
}
```

### ScrapingAgentService

```php
class ScrapingAgentService
{
    public function __construct(
        private ClaudeApiService $claude,
        private ScrapedPropertyValidator $validator,
        private PropertyImportService $importer
    ) {}

    public function scrapeFromHtml(string $html, string $sourceUrl, ?int $jobId = null): ScrapedProperty
    {
        // Call Claude API
        $extracted = $this->claude->analysePropertyHtml($html, $sourceUrl);

        // Validate extracted data
        $this->validator->validate($extracted);

        // Create scraped property record
        return ScrapedProperty::create([
            'scrape_job_id' => $jobId,
            'source_url' => $sourceUrl,
            'source_name' => $extracted['source_name'] ?? $this->inferSourceName($sourceUrl),
            'source_html' => $html,
            'extracted_data' => $extracted,
            'renovation_analysis' => $extracted['renovation_analysis'] ?? [],

            // Denormalised fields
            'property_address' => $extracted['property_address'],
            'postcode' => $extracted['postcode'],
            'price' => $extracted['price'],
            'price_qualifier' => $extracted['price_qualifier'],
            'property_type' => $extracted['property_type'],
            'bedrooms' => $extracted['bedrooms'],
            'bathrooms' => $extracted['bathrooms'],
            'listing_status' => $extracted['status'],
            'condition_type' => $extracted['renovation_analysis']['condition_type'] ?? null,
            'renovation_confidence' => $extracted['renovation_analysis']['confidence'] ?? 'low',
            'requires_work' => $extracted['renovation_analysis']['requires_work'] ?? false,
        ]);
    }

    public function scrapeFromUrl(string $url, ?int $jobId = null): ScrapedProperty
    {
        $html = $this->fetchHtml($url);
        return $this->scrapeFromHtml($html, $url, $jobId);
    }

    public function processBatch(array $items, int $jobId): array
    {
        $results = ['success' => [], 'failed' => []];

        foreach ($items as $item) {
            try {
                $scraped = isset($item['html'])
                    ? $this->scrapeFromHtml($item['html'], $item['url'], $jobId)
                    : $this->scrapeFromUrl($item['url'], $jobId);

                $results['success'][] = $scraped;

                // Rate limiting
                usleep(500000); // 0.5 second delay
            } catch (Exception $e) {
                $results['failed'][] = [
                    'url' => $item['url'] ?? 'unknown',
                    'error' => $e->getMessage()
                ];
            }
        }

        return $results;
    }

    public function approveAndImport(ScrapedProperty $scraped, int $adminId): Property
    {
        $property = $this->importer->import($scraped);

        $scraped->update([
            'status' => 'imported',
            'reviewed_by' => $adminId,
            'reviewed_at' => now(),
            'imported_property_id' => $property->id,
        ]);

        return $property;
    }
}
```

### PropertyImportService

```php
class PropertyImportService
{
    public function import(ScrapedProperty $scraped): Property
    {
        $data = $scraped->extracted_data;
        $analysis = $scraped->renovation_analysis;

        // Create property
        $property = Property::create([
            'user_id' => $this->getSystemUserId(), // Admin/system user
            'slug' => $this->generateSlug($data),
            'title' => $this->generateTitle($data),
            'property_type' => $data['property_type'] ?? 'other',
            'condition_type' => $analysis['condition_type'] ?? 'needs-modernisation',
            'description' => $data['description'] ?? '',
            'price' => $data['price'],
            'price_qualifier' => $this->mapPriceQualifier($data['price_qualifier']),
            'bedrooms' => $data['bedrooms'] ?? 0,
            'bathrooms' => $data['bathrooms'] ?? 0,
            'postcode' => $data['postcode'],
            'postcode_area' => $this->extractPostcodeArea($data['postcode']),
            'city' => $this->extractCity($data['property_address']),
            'address_line_1' => $data['property_address'],
            'status' => 'pending-payment', // Requires manual review/payment
        ]);

        // Import images
        if (!empty($data['images'])) {
            $this->importImages($property, $data['images']);
        }

        // Add features based on analysis
        if (!empty($analysis['indicators_found'])) {
            $this->addFeatures($property, $analysis);
        }

        return $property;
    }
}
```

## Routing Configuration

| Route | Controller | Method | Description |
|-------|------------|--------|-------------|
| `GET /admin/scraping` | ScrapingController | index | Scraping dashboard |
| `GET /admin/scraping/upload` | ScrapingController | upload | Upload form |
| `POST /admin/scraping/analyse` | ScrapingController | analyse | Single HTML analysis |
| `POST /admin/scraping/batch` | ScrapingController | batch | Batch upload |
| `GET /admin/scraping/jobs/{id}` | ScrapingController | jobStatus | Job progress |
| `GET /admin/scraping/review` | ScrapingController | review | Review queue |
| `GET /admin/scraping/review/{id}` | ScrapingController | reviewItem | Review single item |
| `POST /admin/scraping/{id}/approve` | ScrapingController | approve | Approve and import |
| `POST /admin/scraping/{id}/reject` | ScrapingController | reject | Reject with reason |
| `POST /admin/scraping/{id}/edit` | ScrapingController | edit | Edit before import |

## Agent Prompt File

Store the optimised prompt at: `prompts/property-scraper.txt`

This allows easy updates without code changes.

## Configuration

### config/scraping.php
```php
return [
    'claude' => [
        'api_key' => env('ANTHROPIC_API_KEY'),
        'model' => env('CLAUDE_MODEL', 'claude-sonnet-4-20250514'),
    ],

    'rate_limits' => [
        'requests_per_minute' => 20,
        'delay_between_requests_ms' => 500,
    ],

    'batch' => [
        'max_items' => 100,
        'timeout_seconds' => 300,
    ],

    'import' => [
        'system_user_id' => env('SCRAPING_SYSTEM_USER_ID', 1),
        'default_status' => 'pending-payment',
        'download_images' => true,
    ],
];
```

## Error Handling

| Error Type | Handling |
|------------|----------|
| Invalid HTML | Log error, mark job item as failed |
| Claude API timeout | Retry up to 3 times with exponential backoff |
| JSON parse failure | Log raw response, mark as failed for manual review |
| Rate limit exceeded | Queue for later processing |
| Validation failure | Store with errors, allow manual correction |

## Security Considerations

1. **API Key Protection**: Claude API key stored in environment variables
2. **HTML Sanitisation**: Scraped HTML stored but never rendered directly
3. **URL Validation**: Only allow HTTP/HTTPS URLs
4. **Rate Limiting**: Prevent abuse of scraping endpoints
5. **Admin Only**: All scraping features restricted to admin users

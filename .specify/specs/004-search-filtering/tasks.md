# 004 - Search & Filtering Tasks

## Phase 1: Database Setup

### 1.1 Migrations
- [ ] Create `database/migrations/015_create_saved_searches_table.php`
- [ ] Create `database/migrations/016_create_search_logs_table.php`
- [ ] Create `database/migrations/017_create_locations_table.php`
- [ ] Run migrations

### 1.2 Seed Data
- [ ] Seed UK cities and towns (major locations)
- [ ] Seed counties and regions
- [ ] Seed common postcode areas

## Phase 2: Search Service

### 2.1 Core Search
- [ ] Implement `src/Services/SearchService.php`
  - [ ] search() - Main search method
  - [ ] buildQuery() - Query builder with all filters
  - [ ] getFilterCounts() - Counts per filter option
  - [ ] applyTextSearch() - FULLTEXT search
  - [ ] applyFilters() - All filter types
  - [ ] applySorting() - Sort options

### 2.2 Location Service
- [ ] Implement `src/Services/LocationService.php`
  - [ ] autocomplete() - Location suggestions
  - [ ] getPopularLocations() - Common locations
  - [ ] parseLocationQuery() - Handle different formats
  - [ ] geocode() - Get coordinates (optional)

### 2.3 Analytics Service
- [ ] Implement `src/Services/SearchAnalyticsService.php`
  - [ ] logSearch() - Record search
  - [ ] logClick() - Record result click
  - [ ] getPopularSearches() - Analytics data
  - [ ] getZeroResultTerms() - Failed searches

## Phase 3: Repository

### 3.1 Saved Searches
- [ ] Implement `src/Repositories/SavedSearchRepository.php`
  - [ ] findByUser()
  - [ ] create()
  - [ ] update()
  - [ ] delete()
  - [ ] findWithAlerts() - For notification system

## Phase 4: Controllers

### 4.1 Search Controller
- [ ] Implement `src/Controllers/SearchController.php`
  - [ ] index() - Main search results page
  - [ ] category() - SEO category pages
  - [ ] autocomplete() - AJAX autocomplete
  - [ ] save() - Save search criteria
  - [ ] savedSearches() - View saved searches
  - [ ] delete() - Delete saved search
  - [ ] runSaved() - Re-run saved search

## Phase 5: Templates

### 5.1 Filter Components [P]
- [ ] Update `templates/properties/index.php`
  - Integrate filter sidebar
  - Add view toggle
  - Add active filters display

- [ ] Create `templates/properties/partials/filters.php`
  - Property type checkboxes
  - Condition checkboxes
  - Price range inputs
  - Bedroom/bathroom selectors
  - EPC rating checkboxes
  - Apply/Clear buttons

- [ ] Create `templates/properties/partials/active-filters.php`
  - Filter chips display
  - Individual remove buttons
  - Clear all button

- [ ] Create `templates/properties/partials/sort-dropdown.php`
  - Sort option dropdown
  - Current selection display

- [ ] Create `templates/properties/partials/view-toggle.php`
  - Grid/List/Map buttons

- [ ] Create `templates/properties/partials/pagination.php`
  - Page numbers
  - Prev/Next buttons
  - Results count

- [ ] Create `templates/properties/partials/map-view.php`
  - Leaflet map container
  - Property markers

### 5.2 Saved Searches
- [ ] Create `templates/search/saved.php`
  - Saved searches list
  - Run/Edit/Delete actions
  - Alert toggle

## Phase 6: JavaScript Components

### 6.1 Search Bar [P]
- [ ] Create `public/assets/js/components/searchBar.js`
  - Text input handling
  - Debounced autocomplete
  - Recent searches (localStorage)
  - Keyboard navigation
  - Form submission

### 6.2 Filters
- [ ] Create `public/assets/js/components/searchFilters.js`
  - Filter change handlers
  - URL parameter sync
  - Mobile filter toggle
  - Clear all functionality
  - Filter counts update

### 6.3 Map View
- [ ] Create `public/assets/js/components/searchMap.js`
  - Leaflet initialization
  - Property markers
  - Marker clustering
  - Popup cards
  - Bounds fitting
  - View sync with list

### 6.4 Saved Searches
- [ ] Create `public/assets/js/components/savedSearches.js`
  - Save search modal
  - Delete confirmation
  - Alert toggle
  - Run saved search

## Phase 7: SEO & URLs

### 7.1 Category Routes
- [ ] Define category URL mappings
- [ ] Implement category controller method
- [ ] Generate category page content

### 7.2 Meta Tags
- [ ] Dynamic meta titles for search pages
- [ ] Meta descriptions with filter context
- [ ] Canonical URLs for filtered pages
- [ ] Open Graph tags

### 7.3 Structured Data
- [ ] SearchAction schema on homepage
- [ ] ItemList schema on results

## Phase 8: Performance Optimization

### 8.1 Caching
- [ ] Implement location autocomplete caching
- [ ] Implement filter counts caching
- [ ] Add cache invalidation on property updates

### 8.2 Query Optimization
- [ ] Analyze and optimize search queries
- [ ] Add missing indexes if needed
- [ ] Implement query result limits

## Phase 9: Mobile Experience

### 9.1 Responsive Filters
- [ ] Mobile filter drawer/modal
- [ ] Touch-friendly controls
- [ ] Swipe to close
- [ ] Fixed apply button

### 9.2 Mobile Map
- [ ] Mobile-optimized map controls
- [ ] Touch-friendly markers
- [ ] Popup sizing

## Phase 10: Testing

### 10.1 Unit Tests [P]
- [ ] Test SearchService query building
- [ ] Test filter application
- [ ] Test sorting options
- [ ] Test pagination calculations

### 10.2 Integration Tests
- [ ] Test full search flow
- [ ] Test filter combinations
- [ ] Test saved search CRUD
- [ ] Test autocomplete API

### 10.3 UI Tests
- [ ] Test filter interactions
- [ ] Test URL parameter persistence
- [ ] Test mobile filter drawer
- [ ] Test map interactions

## Legend
- [P] = Tasks can be executed in parallel

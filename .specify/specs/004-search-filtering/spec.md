# 004 - Search & Filtering Specification

## Overview

The search and filtering system enables users to find properties matching their specific criteria, including location, property type, price range, condition, and other attributes.

## User Stories

### US-040: Basic Property Search
**As a** visitor
**I want to** search for properties by location
**So that I** can find renovation projects in my desired area

#### Acceptance Criteria
- [ ] Search bar prominently displayed on homepage and header
- [ ] Autocomplete suggestions for:
  - Cities/towns
  - Counties/regions
  - Postcode areas (e.g., "SW1", "M1")
- [ ] Search results page with matching properties
- [ ] "No results" message with suggestions if empty
- [ ] Recent searches saved (localStorage)

### US-041: Advanced Filtering
**As a** buyer
**I want to** filter properties by multiple criteria
**So that I** can narrow down to relevant listings

#### Acceptance Criteria
- [ ] Filter by property type (multi-select):
  - Detached House
  - Semi-Detached
  - Terraced
  - Flat/Apartment
  - Bungalow
  - Other types
- [ ] Filter by condition (multi-select):
  - Needs Total Renovation
  - Structural Issues
  - Needs Modernisation
  - Cosmetic Updates
  - Good Condition
- [ ] Filter by price range:
  - Min price (dropdown or input)
  - Max price (dropdown or input)
  - Common presets (Under £100k, £100k-£200k, etc.)
- [ ] Filter by bedrooms:
  - Min bedrooms (0-10+)
  - Max bedrooms (0-10+)
- [ ] Filter by bathrooms:
  - Min bathrooms
  - Max bathrooms
- [ ] Filter by living area (optional):
  - Min sq ft
  - Max sq ft
- [ ] Filter by EPC rating (multi-select)
- [ ] Show property count per filter option
- [ ] Clear all filters button
- [ ] Active filters displayed as removable chips

### US-042: Sort Results
**As a** buyer
**I want to** sort search results
**So that I** can see properties in my preferred order

#### Acceptance Criteria
- [ ] Sort options:
  - Newest first (default)
  - Price: Low to High
  - Price: High to Low
  - Bedrooms: Most first
  - Most viewed
- [ ] Selected sort option persists during session
- [ ] Premium listings always appear first in each sort

### US-043: Map View
**As a** buyer
**I want to** view properties on a map
**So that I** can understand their geographic distribution

#### Acceptance Criteria
- [ ] Toggle between grid view and map view
- [ ] Map displays property markers (clustered when zoomed out)
- [ ] Clicking marker shows property preview card
- [ ] Map bounds update based on search/filters
- [ ] Property list syncs with visible map area (optional)
- [ ] Mobile-friendly map interaction

### US-044: Save Search
**As a** logged-in buyer
**I want to** save my search criteria
**So that I** can quickly re-run searches

#### Acceptance Criteria
- [ ] "Save this search" button on results page
- [ ] Name the saved search
- [ ] View saved searches in dashboard
- [ ] One-click to re-run saved search
- [ ] Delete saved searches
- [ ] Option to receive alerts for saved search (links to alerts feature)

### US-045: Search by Location Type
**As a** buyer
**I want to** search by different location types
**So that I** can find properties in flexible geographic areas

#### Acceptance Criteria
- [ ] Search by:
  - City/Town name
  - County/Region
  - Postcode (full or partial)
  - Draw on map (future enhancement)
- [ ] Radius search from a point (e.g., within 10 miles of Manchester)
- [ ] Multiple locations in single search (e.g., "Leeds or Manchester")

### US-046: Quick Filters
**As a** visitor
**I want to** use quick filter shortcuts
**So that I** can start browsing immediately

#### Acceptance Criteria
- [ ] Homepage quick links:
  - "Under £100,000"
  - "Needs Total Renovation"
  - "3+ Bedrooms"
  - Popular regions (London, Manchester, Birmingham, etc.)
- [ ] Category pages for common searches
- [ ] SEO-friendly URLs for filter combinations

## Non-Functional Requirements

### Performance
- Search results load < 1.5 seconds
- Filter updates feel instant (< 500ms)
- Autocomplete suggestions < 300ms
- Pagination maintains filter state

### SEO
- Search result pages crawlable
- Filter combinations generate unique URLs
- Canonical URLs to prevent duplicate content
- Structured data for search actions

### Accessibility
- Filters operable by keyboard
- Clear focus states
- Screen reader announcements for results updates
- Mobile touch targets appropriately sized

## Filter URL Structure

```
/properties?location=manchester&type[]=detached&type[]=semi-detached&condition[]=needs-modernisation&min_price=50000&max_price=200000&min_beds=3&sort=price-asc&page=2
```

## UI Components Required

1. **Search Bar Component**
   - Text input with search icon
   - Autocomplete dropdown
   - Recent searches list
   - Clear button

2. **Filter Sidebar/Panel**
   - Collapsible sections on mobile
   - Checkbox groups for multi-select
   - Range inputs for price/beds
   - Apply/Clear buttons on mobile

3. **Active Filters Chips**
   - Displayed above results
   - Individual remove buttons
   - Clear all button

4. **Sort Dropdown**
   - Current selection displayed
   - Dropdown with options

5. **View Toggle**
   - Grid/List/Map view buttons
   - Active state indicator

6. **Results Count**
   - "Showing X of Y properties"
   - Filter context

7. **Pagination Component**
   - Page numbers
   - Prev/Next buttons
   - Items per page selector

8. **Map View Component**
   - Full-width map
   - Clustered markers
   - Property preview popups
   - Controls (zoom, type toggle)

## Search Analytics

Track the following for product insights:
- Most common search terms
- Most used filter combinations
- Average filters applied per search
- Search-to-inquiry conversion rate
- Zero-result search terms
- Popular saved searches

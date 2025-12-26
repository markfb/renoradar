# 004 - Search & Filtering Technical Plan

## Architecture Overview

The search system uses MySQL FULLTEXT indexing for text search combined with indexed column queries for filtering. For map functionality, we use Leaflet.js with OpenStreetMap tiles (free, no API key required).

## Directory Structure

```
src/
├── Controllers/
│   └── SearchController.php
├── Services/
│   ├── SearchService.php
│   ├── LocationService.php
│   └── SearchAnalyticsService.php
└── Repositories/
    └── SavedSearchRepository.php

templates/
├── properties/
│   ├── index.php           # Main search results
│   └── partials/
│       ├── filters.php     # Filter sidebar
│       ├── active-filters.php
│       ├── sort-dropdown.php
│       ├── view-toggle.php
│       ├── pagination.php
│       └── map-view.php
└── search/
    └── saved.php           # Saved searches page

public/assets/js/
└── components/
    ├── searchBar.js
    ├── searchFilters.js
    ├── searchMap.js
    └── savedSearches.js
```

## Routing Configuration

| Route | Controller | Method | Description |
|-------|------------|--------|-------------|
| `GET /properties` | SearchController | index | Search results with filters |
| `GET /api/search/autocomplete` | SearchController | autocomplete | Location suggestions |
| `POST /api/search/save` | SearchController | save | Save search criteria |
| `GET /saved-searches` | SearchController | savedSearches | View saved searches |
| `DELETE /api/search/{id}` | SearchController | delete | Delete saved search |

## Database Schema

### saved_searches
```sql
CREATE TABLE saved_searches (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    name VARCHAR(100) NOT NULL,
    criteria JSON NOT NULL,
    alert_enabled TINYINT(1) DEFAULT 0,
    last_run_at TIMESTAMP NULL,
    results_count INT UNSIGNED DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_alert (alert_enabled)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### search_logs (Analytics)
```sql
CREATE TABLE search_logs (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NULL,
    session_id VARCHAR(64),
    search_term VARCHAR(200),
    filters JSON,
    results_count INT UNSIGNED,
    clicked_property_id INT UNSIGNED NULL,
    ip_address VARCHAR(45),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_user (user_id),
    INDEX idx_created (created_at),
    INDEX idx_term (search_term)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### locations (Reference Data)
```sql
CREATE TABLE locations (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type ENUM('city', 'town', 'county', 'region', 'postcode_area') NOT NULL,
    parent_id INT UNSIGNED NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    property_count INT UNSIGNED DEFAULT 0,

    FOREIGN KEY (parent_id) REFERENCES locations(id) ON DELETE SET NULL,
    INDEX idx_name (name),
    INDEX idx_type (type),
    FULLTEXT idx_search (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

## Search Service Implementation

### SearchService

```php
class SearchService
{
    public function search(array $params): PaginatedResult
    {
        $query = $this->buildQuery($params);
        return $this->paginate($query, $params['page'] ?? 1, $params['per_page'] ?? 12);
    }

    private function buildQuery(array $params): QueryBuilder
    {
        $query = Property::query()
            ->where('status', 'active')
            ->whereNull('deleted_at');

        // Text search
        if (!empty($params['q'])) {
            $query->whereRaw(
                "MATCH(title, description) AGAINST(? IN NATURAL LANGUAGE MODE)",
                [$params['q']]
            );
        }

        // Location filter
        if (!empty($params['location'])) {
            $query->where(function ($q) use ($params) {
                $q->where('city', 'LIKE', "%{$params['location']}%")
                  ->orWhere('county', 'LIKE', "%{$params['location']}%")
                  ->orWhere('postcode_area', $params['location']);
            });
        }

        // Property type filter
        if (!empty($params['type'])) {
            $types = is_array($params['type']) ? $params['type'] : [$params['type']];
            $query->whereIn('property_type', $types);
        }

        // Condition filter
        if (!empty($params['condition'])) {
            $conditions = is_array($params['condition']) ? $params['condition'] : [$params['condition']];
            $query->whereIn('condition_type', $conditions);
        }

        // Price range
        if (!empty($params['min_price'])) {
            $query->where('price', '>=', (int)$params['min_price']);
        }
        if (!empty($params['max_price'])) {
            $query->where('price', '<=', (int)$params['max_price']);
        }

        // Bedrooms
        if (!empty($params['min_beds'])) {
            $query->where('bedrooms', '>=', (int)$params['min_beds']);
        }
        if (!empty($params['max_beds'])) {
            $query->where('bedrooms', '<=', (int)$params['max_beds']);
        }

        // Bathrooms
        if (!empty($params['min_baths'])) {
            $query->where('bathrooms', '>=', (int)$params['min_baths']);
        }

        // EPC rating
        if (!empty($params['epc'])) {
            $ratings = is_array($params['epc']) ? $params['epc'] : [$params['epc']];
            $query->whereIn('epc_rating', $ratings);
        }

        // Sorting (premium always first)
        $query->orderByDesc('is_premium');

        switch ($params['sort'] ?? 'newest') {
            case 'price-asc':
                $query->orderBy('price', 'ASC');
                break;
            case 'price-desc':
                $query->orderBy('price', 'DESC');
                break;
            case 'beds-desc':
                $query->orderBy('bedrooms', 'DESC');
                break;
            case 'views':
                $query->orderBy('view_count', 'DESC');
                break;
            default: // newest
                $query->orderBy('published_at', 'DESC');
        }

        return $query;
    }

    public function getFilterCounts(array $currentFilters): array
    {
        // Return counts for each filter option based on current selection
        // Used to show "Detached (45)" in filter UI
    }
}
```

### LocationService

```php
class LocationService
{
    public function autocomplete(string $query, int $limit = 10): array
    {
        // Search locations table
        $locations = Location::whereRaw(
            "MATCH(name) AGAINST(? IN BOOLEAN MODE)",
            [$query . '*']
        )->limit($limit)->get();

        // Also search postcode areas from properties
        $postcodes = Property::select('postcode_area')
            ->where('postcode_area', 'LIKE', $query . '%')
            ->groupBy('postcode_area')
            ->limit(5)
            ->get();

        return $this->mergeAndRank($locations, $postcodes);
    }

    public function getPopularLocations(int $limit = 10): array
    {
        return Location::orderBy('property_count', 'DESC')
            ->limit($limit)
            ->get();
    }
}
```

## Frontend Components

### Search Bar with Autocomplete

```javascript
// components/searchBar.js
class SearchBar {
    constructor(element) {
        this.input = element.querySelector('input');
        this.dropdown = element.querySelector('.autocomplete-dropdown');
        this.debounceTimer = null;

        this.init();
    }

    init() {
        this.input.addEventListener('input', () => this.handleInput());
        this.input.addEventListener('focus', () => this.showRecent());
        document.addEventListener('click', (e) => this.handleClickOutside(e));
    }

    async handleInput() {
        clearTimeout(this.debounceTimer);
        const query = this.input.value.trim();

        if (query.length < 2) {
            this.hideDropdown();
            return;
        }

        this.debounceTimer = setTimeout(async () => {
            const results = await this.fetchSuggestions(query);
            this.renderSuggestions(results);
        }, 200);
    }

    async fetchSuggestions(query) {
        const response = await fetch(`/api/search/autocomplete?q=${encodeURIComponent(query)}`);
        return response.json();
    }

    renderSuggestions(results) {
        // Render dropdown with results
    }

    showRecent() {
        const recent = JSON.parse(localStorage.getItem('recentSearches') || '[]');
        if (recent.length && !this.input.value) {
            this.renderRecent(recent);
        }
    }

    saveRecent(term) {
        let recent = JSON.parse(localStorage.getItem('recentSearches') || '[]');
        recent = [term, ...recent.filter(t => t !== term)].slice(0, 5);
        localStorage.setItem('recentSearches', JSON.stringify(recent));
    }
}
```

### Filter Panel

```javascript
// components/searchFilters.js
class SearchFilters {
    constructor(element) {
        this.form = element;
        this.init();
    }

    init() {
        // Handle checkbox changes
        this.form.querySelectorAll('input[type="checkbox"]').forEach(cb => {
            cb.addEventListener('change', () => this.applyFilters());
        });

        // Handle range inputs
        this.form.querySelectorAll('select, input[type="number"]').forEach(input => {
            input.addEventListener('change', () => this.applyFilters());
        });

        // Clear all button
        this.form.querySelector('.clear-filters')?.addEventListener('click', () => {
            this.clearAll();
        });
    }

    applyFilters() {
        const params = new URLSearchParams(window.location.search);

        // Update URL with current filter state
        this.form.querySelectorAll('input, select').forEach(input => {
            if (input.type === 'checkbox') {
                // Handle arrays for checkboxes
            } else if (input.value) {
                params.set(input.name, input.value);
            } else {
                params.delete(input.name);
            }
        });

        window.location.search = params.toString();
    }

    clearAll() {
        window.location.href = '/properties';
    }
}
```

### Map View

```javascript
// components/searchMap.js
class PropertyMap {
    constructor(element, properties) {
        this.container = element;
        this.properties = properties;
        this.map = null;
        this.markers = [];

        this.init();
    }

    init() {
        // Initialize Leaflet map
        this.map = L.map(this.container).setView([54.5, -2], 6); // UK center

        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '© OpenStreetMap contributors'
        }).addTo(this.map);

        this.addMarkers();
        this.fitBounds();
    }

    addMarkers() {
        this.properties.forEach(property => {
            if (property.latitude && property.longitude) {
                const marker = L.marker([property.latitude, property.longitude])
                    .bindPopup(this.createPopup(property))
                    .addTo(this.map);
                this.markers.push(marker);
            }
        });
    }

    createPopup(property) {
        return `
            <div class="property-popup">
                <img src="${property.thumbnail}" alt="">
                <h4>${property.title}</h4>
                <p class="price">£${property.price.toLocaleString()}</p>
                <a href="/properties/${property.slug}">View Details</a>
            </div>
        `;
    }

    fitBounds() {
        if (this.markers.length > 0) {
            const group = L.featureGroup(this.markers);
            this.map.fitBounds(group.getBounds().pad(0.1));
        }
    }
}
```

## URL Parameter Handling

### Filter Parameter Mapping

| Parameter | Type | Example | Description |
|-----------|------|---------|-------------|
| q | string | `q=london` | Text search |
| location | string | `location=manchester` | Location filter |
| type[] | array | `type[]=detached&type[]=semi` | Property types |
| condition[] | array | `condition[]=needs-modernisation` | Conditions |
| min_price | int | `min_price=100000` | Minimum price |
| max_price | int | `max_price=500000` | Maximum price |
| min_beds | int | `min_beds=3` | Minimum bedrooms |
| max_beds | int | `max_beds=5` | Maximum bedrooms |
| min_baths | int | `min_baths=2` | Minimum bathrooms |
| epc[] | array | `epc[]=A&epc[]=B` | EPC ratings |
| sort | string | `sort=price-asc` | Sort order |
| page | int | `page=2` | Pagination |
| view | string | `view=map` | View mode |

## SEO-Friendly URLs

### Category Pages

| URL | Filters Applied |
|-----|-----------------|
| `/properties/london` | location=london |
| `/properties/under-100k` | max_price=100000 |
| `/properties/total-renovation` | condition=total-renovation |
| `/properties/detached-houses` | type=detached |
| `/properties/3-bed` | min_beds=3, max_beds=3 |

### Implementation

```php
// routes.php
$router->get('/properties/{category}', [SearchController::class, 'category']);

// SearchController.php
public function category(string $category): Response
{
    $filters = $this->categoryToFilters($category);
    return $this->index(new Request(['filters' => $filters]));
}

private function categoryToFilters(string $category): array
{
    $mapping = [
        'london' => ['location' => 'London'],
        'under-100k' => ['max_price' => 100000],
        'total-renovation' => ['condition' => 'total-renovation'],
        'detached-houses' => ['type' => 'detached'],
        // ... more mappings
    ];

    return $mapping[$category] ?? [];
}
```

## Caching Strategy

1. **Location Autocomplete**: Cache popular queries for 1 hour
2. **Filter Counts**: Cache counts per filter combination for 5 minutes
3. **Category Pages**: Full page cache for 5 minutes
4. **Search Results**: No caching (always fresh data)

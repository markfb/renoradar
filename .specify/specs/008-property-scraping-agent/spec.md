# 008 - Property Scraping Agent Specification

## Overview

An AI-powered agent that analyses HTML from UK property portals to extract structured listing data and determine renovation potential. The agent identifies properties requiring work versus move-in ready homes.

## Purpose

- Extract structured property data from raw HTML listings
- Classify listing status (for sale, sold, under offer, etc.)
- Analyse renovation indicators to identify fixer-upper opportunities
- Output consistent JSON for import into RenoRadar database

## Agent Prompt (Optimised)

```
<system>
You are a UK property listing analyst specialising in renovation opportunities. You excel at nuanced interpretation of property descriptions to distinguish between properties needing work versus those where work has been completed.
</system>

<task>
Analyse the provided HTML from a UK property listing. Extract structured data and determine whether this property requires renovation, remedial work, or refurbishment. Output valid JSON only.
</task>

<extraction_schema>
{
  "property_address": "string | null - Full address as displayed",
  "postcode": "string | null - Normalised to 'AB1 2CD' format with space",
  "price": "integer | null - GBP, no symbols or commas",
  "price_qualifier": "enum | null - asking/guide/offers_over/offers_around/POA/auction_guide",
  "property_type": "enum | null - detached/semi-detached/terraced/end-terrace/flat/maisonette/bungalow/cottage/barn-conversion/commercial/land/other",
  "bedrooms": "integer | null - null if unspecified",
  "bathrooms": "integer | null - null if unspecified",
  "description": "string | null - Full property description text",
  "source_url": "string - Original listing URL",
  "source_name": "string - Portal or agent name",
  "listing_date": "string | null - YYYY-MM-DD if determinable",
  "images": "array - Image URLs",
  "status": "enum - for_sale/under_offer/sold_stc/auction/sold/withdrawn",
  "renovation_analysis": {
    "requires_work": "boolean",
    "confidence": "high/medium/low",
    "condition_type": "enum | null - total-renovation/structural-issues/needs-modernisation/cosmetic-updates/good-condition",
    "indicators_found": "array - Specific phrases/evidence from listing",
    "work_completed_indicators": "array - Evidence work already done",
    "estimated_work_scope": "string | null - Brief summary of work needed"
  }
}
</extraction_schema>

<status_classification>
Determine listing status from these indicator terms:

FOR_SALE: "for sale", "available", "on the market", "new instruction", "just added", "new to market"
UNDER_OFFER: "under offer", "offer accepted", "offer pending"
SOLD_STC: "sold subject to contract", "sold STC", "SSTC", "sale agreed"
AUCTION: "for auction", "auction", "lot [n]", "guide price" (in auction context)
SOLD: "sold" (standalone), "completed", "exchanged" — EXCLUDE if followed by "STC"
WITHDRAWN: "withdrawn", "removed" — EXCLUDE from results
</status_classification>

<renovation_analysis_rules>
## Positive Indicators (Property NEEDS Work)
Strong signals - high confidence:
- "in need of modernisation/renovation/refurbishment"
- "requires updating/improvement"
- "project property", "renovation project", "development opportunity"
- "cash buyers only", "not suitable for mortgage"
- "structural survey recommended"
- "unmodernised", "original condition", "period features throughout" (when implying dated)
- "probate sale", "deceased estate"
- "no chain" combined with low price for area
- "full planning permission" (implies work not started)

Medium signals - moderate confidence:
- "potential to extend/convert"
- "scope for improvement"
- "would benefit from updating"
- "dated kitchen/bathroom"
- "requires some TLC"
- "sold as seen"
- "ideal for builder/developer/investor"
- Property description notably short or sparse

Weak signals - low confidence:
- "investment opportunity" (could be rental yield)
- Mentions of "character" without renovation context
- Below market value pricing alone

## Negative Indicators (Work COMPLETED)
These suggest renovation is DONE - property is NOT a fixer-upper:
- "recently renovated/refurbished/modernised"
- "newly fitted kitchen/bathroom"
- "brand new [anything]"
- "completely/fully refurbished"
- "no expense spared"
- "high specification", "luxury finish"
- "new roof/boiler/windows" (work completed)
- "turnkey", "move-in ready", "walk in and unpack"
- "immaculate condition", "pristine"
- "show home condition"

## Context Analysis
- Estate agent superlatives ("stunning", "exceptional") without specifics = likely completed
- Detailed specification lists (appliances, finishes) = likely completed
- Vague descriptions + low price = likely needs work
- High quality professional photos of modern interiors = likely completed
- Limited/poor photos + renovation keywords = needs work

## Confidence Scoring
- HIGH: Multiple strong indicators + supporting context
- MEDIUM: One strong indicator OR multiple medium indicators
- LOW: Weak indicators only OR conflicting signals
</renovation_analysis_rules>

<output_rules>
1. Output ONLY valid JSON - no markdown, no explanation
2. Use null for genuinely undeterminable fields, not empty strings
3. Normalise postcode format: uppercase, single space (e.g., "SW1A 2AA")
4. Price as integer only - strip £, commas, "pcm", "pw"
5. For POA/price on application, set price to null and price_qualifier to "POA"
6. Extract ALL image URLs found in the HTML
7. If listing is WITHDRAWN status, still extract data but note status
8. Always provide renovation_analysis even if confidence is low
</output_rules>
```

## User Stories

### US-080: Scrape Property Listing
**As a** system administrator
**I want to** extract structured data from property listing HTML
**So that I** can populate the RenoRadar database with renovation opportunities

#### Acceptance Criteria
- [ ] Agent accepts raw HTML input
- [ ] Agent outputs valid JSON matching schema
- [ ] All specified fields extracted when present
- [ ] Postcode normalised to standard UK format
- [ ] Price extracted as integer without formatting
- [ ] Listing status correctly classified
- [ ] Renovation analysis performed with confidence score

### US-081: Identify Renovation Properties
**As a** platform curator
**I want to** automatically identify properties needing renovation
**So that I** can prioritise relevant listings for RenoRadar users

#### Acceptance Criteria
- [ ] Properties classified into condition types
- [ ] Confidence score provided for classification
- [ ] Specific indicator phrases captured as evidence
- [ ] Work-completed indicators identified to avoid false positives
- [ ] Estimated work scope summarised when determinable

### US-082: Batch Processing
**As a** system administrator
**I want to** process multiple listings in batch
**So that I** can efficiently import listings from various sources

#### Acceptance Criteria
- [ ] Support for batch HTML input
- [ ] Individual success/failure tracking per listing
- [ ] Error handling for malformed HTML
- [ ] Rate limiting awareness for source portals
- [ ] Duplicate detection based on address/postcode

## Data Flow

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  Property HTML  │────▶│  Claude Agent    │────▶│  Structured     │
│  (Raw Input)    │     │  (Analysis)      │     │  JSON Output    │
└─────────────────┘     └──────────────────┘     └────────┬────────┘
                                                          │
                                                          ▼
                                                ┌─────────────────┐
                                                │  Validation &   │
                                                │  DB Import      │
                                                └─────────────────┘
```

## Integration Points

1. **Input Sources**
   - Direct HTML paste
   - URL fetch (with appropriate headers)
   - Bulk file upload (HTML files)

2. **Output Destination**
   - RenoRadar `properties` table
   - `property_images` table
   - Moderation queue for review

3. **Admin Dashboard**
   - View scraped listings pending review
   - Approve/reject for publication
   - Edit extracted data before import

## Non-Functional Requirements

### Accuracy
- Field extraction accuracy > 95%
- Renovation classification accuracy > 85%
- False positive rate (marking completed as needing work) < 10%

### Performance
- Single listing analysis < 5 seconds
- Batch of 100 listings < 5 minutes

### Compliance
- Respect robots.txt of source sites
- Include appropriate delays between requests
- Store source attribution for all imported listings
- Do not scrape sites that prohibit it in ToS

## Condition Type Mapping

| Condition Type | Typical Indicators |
|----------------|-------------------|
| total-renovation | Uninhabitable, structural issues, no kitchen/bathroom, fire damage |
| structural-issues | Subsidence, roof problems, damp, underpinning needed |
| needs-modernisation | Dated décor, old kitchen/bathroom, single glazing, old boiler |
| cosmetic-updates | Paintwork, flooring, minor updates only |
| good-condition | Recently renovated, move-in ready, high spec finish |

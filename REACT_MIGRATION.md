# React Frontend Architecture

## Overview

This project uses a React-based static site frontend with a JSON API backend.

## Architecture

- **Frontend**: React SPA hosted on S3 + CloudFront
  - All UI components rendered client-side
  - Hash-based routing for SPA navigation
  - Dark/Light theme support
- **Backend**: Single `draw` Lambda with JSON API
  - Accepts JSON requests
  - Returns structured JSON data
  - Maintains all card shuffling and deck logic
- **Security**: CORS restricted to frontend domain only

## Features

- ✅ Tarot card drawing with multiple deck options
- ✅ Dark/Light theme toggle
- ✅ Responsive design
- ✅ Client-side routing
- ✅ Secure backend (CORS-restricted)

## Development

See [`frontend/README.md`](frontend/README.md) for frontend development details.
See [`terraform-frontend/README.md`](terraform-frontend/README.md) for infrastructure deployment.

## API Contract

```json
// POST /draw
{
  "deckSize": "Full Deck",
  "deckReverse": "Upright and reversed",
  "numCards": 8
}
```

Response includes drawn cards with image URLs and reversal status.
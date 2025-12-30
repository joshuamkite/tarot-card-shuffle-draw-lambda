# AI Agent Development Guide

## Project Overview
Tarot card shuffle and draw application with a React frontend and AWS Lambda backend. Users can draw random tarot cards with configurable deck sizes and reversal options.

## Architecture

### Frontend
- **Framework**: React 19 with Vite
- **Deployment**: S3 + CloudFront
- **Domain**: https://tarot-shuffle-draw.joshuakite.co.uk
- **Key Features**: 
  - Card drawing interface with options
  - Responsive grid layout (4 cols desktop, 3 cols medium, 2 cols tablet, 1 col mobile)
  - Light/dark theme support
  - License information display

### Backend
- **Runtime**: AWS Lambda (Go 1.x)
- **API**: API Gateway HTTP API
- **Domain**: https://tarot-shuffle-draw-react-backend.joshuakite.co.uk
- **Endpoints**: 
  - `POST /draw` - Draw cards with parameters (deckSize, deckReverse, numCards)
- **Assets**: Tarot card images stored in S3

### Infrastructure
- **IaC**: OpenTofu (Terraform)
- **Region**: eu-west-2 (London)
- **State**: Remote in S3 bucket

## Tech Stack

### Frontend (`/frontend`)
- React 19.2.0
- Vite 7.2.4
- PropTypes for type checking
- CSS custom properties for theming
- Environment variables via `VITE_API_URL`

### Backend (`/draw`)
- Go (Lambda runtime)
- Fisher-Yates shuffle algorithm
- Unit tests with table-driven testing

### Infrastructure (`/terraform`)
- OpenTofu/Terraform
- AWS API Gateway v2 (HTTP API)
- CloudFront for CDN
- S3 for static assets and frontend hosting
- CloudWatch for logging

## Development Workflow

### Local Development Setup

1. **Frontend**:
   ```bash
   cd frontend
   npm install
   npm run dev
   ```
   - Dev server runs on http://localhost:5173
   - Vite proxy forwards `/draw` to production API (bypasses CORS)
   - Hot module replacement enabled

2. **Backend** (Testing):
   ```bash
   cd draw
   go test -v
   ```

### Environment Variables

- **Production Build**: Set `VITE_API_URL` during build
  ```bash
  VITE_API_URL=https://api.example.com npm run build
  ```
- **Local Development**: Uses Vite proxy (no env var needed)

### CORS Configuration
- API Gateway CORS is restricted to production frontend domain
- Local dev uses Vite proxy to avoid CORS issues
- See `frontend/vite.config.js` for proxy config

## Key Files & Directories

### Frontend Structure
```
frontend/
├── src/
│   ├── App.jsx                 # Main app component, routing logic
│   ├── App.css                 # Theme variables, responsive styles
│   ├── components/
│   │   ├── CardDisplay.jsx     # Displays drawn cards in grid
│   │   ├── LicensePage.jsx     # License information overlay
│   │   └── OptionsForm.jsx     # Card drawing options form
│   ├── contexts/
│   │   └── ThemeContext.jsx    # Light/dark theme provider
│   └── services/
│       └── api.js              # API client for backend
├── vite.config.js              # Vite config with dev proxy
└── package.json
```

### Backend Structure
```
draw/
├── main.go                     # Lambda handler, shuffle logic
├── main_test.go                # Unit tests
├── go.mod                      # Go dependencies
└── makefile                    # Build commands
```

### Infrastructure
```
terraform/
├── main.tf                     # Provider and locals
├── variables.tf                # Input variables
├── terraform.tfvars            # Variable values (domain names, etc.)
├── api_gateway.tf              # API Gateway HTTP API + CORS
├── lambda.tf                   # Lambda functions
├── frontend.tf                 # Frontend S3 + CloudFront
├── s3.tf                       # S3 buckets for images
└── outputs.tf                  # Output values
```

## Common Development Tasks

### Adding New API Endpoints
1. Update Lambda handler in `draw/main.go`
2. Add route in `terraform/api_gateway.tf` → `local.api_routes`
3. Update CORS if needed (`cors_configuration`)
4. Update frontend `api.js` with new function

### Modifying Card Display Layout
- Edit `frontend/src/App.css` → `.cards-container` section
- Responsive breakpoints: 1200px, 900px, 600px
- Test by resizing browser or using dev tools

### Updating Tarot Card Images
- Upload to S3 bucket (see `terraform/outputs.tf` for bucket name)
- Images follow naming convention: `Cups01.jpg`, `RWS_Tarot_00_Fool.jpg`, etc.
- Images served via CloudFront CDN

### Theme Customization
- Edit CSS custom properties in `frontend/src/App.css`
- Two themes: `[data-theme="light"]` and `[data-theme="dark"]`
- Theme toggle in `ThemeContext.jsx`

## Deployment

### Frontend Deployment
```bash
cd frontend
VITE_API_URL=https://tarot-shuffle-draw-react-backend.joshuakite.co.uk npm run build
# Upload dist/ to S3 bucket
# Invalidate CloudFront cache
./dev_tooling/cloudfront-invalidation.sh
```

### Backend Deployment
```bash
cd draw
make build
# Deploy via Terraform/OpenTofu
cd ../terraform
tofu apply
```

### Infrastructure Changes
```bash
cd terraform
tofu plan
tofu apply
```

## Testing

### Frontend
- Manual testing via browser
- Responsive testing: resize browser or use dev tools device emulation

### Backend
```bash
cd draw
go test -v                    # Run all tests
go test -v -run TestShuffle   # Run specific test
```

### API Testing
```bash
# Using test script
./dev_tooling/test_scripts/test_api_connection.sh

# Manual curl
curl -X POST https://tarot-shuffle-draw-react-backend.joshuakite.co.uk/draw \
  -H "Content-Type: application/json" \
  -d '{"deckSize":"major","deckReverse":"reversals","numCards":3}'
```

## Troubleshooting

### CORS Issues
- **Production**: Check `terraform/api_gateway.tf` → `cors_configuration`
- **Local Dev**: Verify Vite proxy in `frontend/vite.config.js`
- **Symptom**: "Failed to fetch" in browser console

### Image Loading Issues
- Check S3 bucket public access settings
- Verify CloudFront distribution status
- Check browser network tab for 403/404 errors

### API Gateway 403 Errors
- Verify route configuration in `api_gateway.tf`
- Check Lambda permissions
- Review CloudWatch logs

## Useful Commands

```bash
# Frontend dev server
cd frontend && npm run dev

# Frontend build
cd frontend && VITE_API_URL=<url> npm run build

# Backend tests
cd draw && go test -v

# Backend build
cd draw && make build

# Infrastructure plan
cd terraform && tofu plan

# Infrastructure apply
cd terraform && tofu apply

# CloudFront invalidation
./dev_tooling/cloudfront-invalidation.sh
```

## Project Conventions

- **Commits**: Use conventional commit format
- **Branches**: Feature branches from main
- **Go Code**: Follow standard Go formatting (`gofmt`)
- **React**: Functional components with hooks
- **CSS**: Use CSS custom properties for theming
- **Responsive**: Mobile-first with min-width media queries

## Known Limitations

- CORS restricted to production domain only
- No backend error handling for malformed requests (API Gateway validates)
- No card draw history/persistence
- No user accounts or saved readings

## Future Enhancements

- Card interpretation/meanings display
- Save and share readings
- Multiple spread layouts (Celtic Cross, 3-card, etc.)
- Backend card meanings API
- User authentication
- Draw history

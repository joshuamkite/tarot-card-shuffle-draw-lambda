package main

import (
	"encoding/json"
	"os"
	"testing"

	"github.com/aws/aws-lambda-go/events"
)

func TestDrawHandler_OPTIONS(t *testing.T) {
	// Set environment variable for testing
	os.Setenv("CLOUDFRONT_URL", "https://test.cloudfront.net")

	req := events.APIGatewayV2HTTPRequest{
		RequestContext: events.APIGatewayV2HTTPRequestContext{
			HTTP: events.APIGatewayV2HTTPRequestContextHTTPDescription{
				Method: "OPTIONS",
			},
		},
	}

	resp, err := drawHandler(req)
	if err != nil {
		t.Fatalf("Expected no error, got %v", err)
	}

	if resp.StatusCode != 200 {
		t.Errorf("Expected status 200, got %d", resp.StatusCode)
	}

	if resp.Headers["Access-Control-Allow-Origin"] == "" {
		t.Error("Expected CORS headers to be set")
	}
}

func TestDrawHandler_InvalidMethod(t *testing.T) {
	os.Setenv("CLOUDFRONT_URL", "https://test.cloudfront.net")

	req := events.APIGatewayV2HTTPRequest{
		RequestContext: events.APIGatewayV2HTTPRequestContext{
			HTTP: events.APIGatewayV2HTTPRequestContextHTTPDescription{
				Method: "GET",
			},
		},
	}

	resp, err := drawHandler(req)
	if err != nil {
		t.Fatalf("Expected no error, got %v", err)
	}

	if resp.StatusCode != 405 {
		t.Errorf("Expected status 405, got %d", resp.StatusCode)
	}

	var errorResp errorResponse
	if err := json.Unmarshal([]byte(resp.Body), &errorResp); err != nil {
		t.Fatalf("Failed to parse error response: %v", err)
	}

	if errorResp.Error != "method_not_allowed" {
		t.Errorf("Expected error 'method_not_allowed', got '%s'", errorResp.Error)
	}
}

func TestDrawHandler_InvalidJSON(t *testing.T) {
	os.Setenv("CLOUDFRONT_URL", "https://test.cloudfront.net")

	req := events.APIGatewayV2HTTPRequest{
		RequestContext: events.APIGatewayV2HTTPRequestContext{
			HTTP: events.APIGatewayV2HTTPRequestContextHTTPDescription{
				Method: "POST",
			},
		},
		Body: "invalid json",
	}

	resp, err := drawHandler(req)
	if err != nil {
		t.Fatalf("Expected no error, got %v", err)
	}

	if resp.StatusCode != 400 {
		t.Errorf("Expected status 400, got %d", resp.StatusCode)
	}

	var errorResp errorResponse
	if err := json.Unmarshal([]byte(resp.Body), &errorResp); err != nil {
		t.Fatalf("Failed to parse error response: %v", err)
	}

	if errorResp.Error != "invalid_request" {
		t.Errorf("Expected error 'invalid_request', got '%s'", errorResp.Error)
	}
}

func TestDrawHandler_MissingParameters(t *testing.T) {
	os.Setenv("CLOUDFRONT_URL", "https://test.cloudfront.net")

	req := events.APIGatewayV2HTTPRequest{
		RequestContext: events.APIGatewayV2HTTPRequestContext{
			HTTP: events.APIGatewayV2HTTPRequestContextHTTPDescription{
				Method: "POST",
			},
		},
		Body: `{"numCards": 5}`,
	}

	resp, err := drawHandler(req)
	if err != nil {
		t.Fatalf("Expected no error, got %v", err)
	}

	if resp.StatusCode != 400 {
		t.Errorf("Expected status 400, got %d", resp.StatusCode)
	}

	var errorResp errorResponse
	if err := json.Unmarshal([]byte(resp.Body), &errorResp); err != nil {
		t.Fatalf("Failed to parse error response: %v", err)
	}

	if errorResp.Error != "missing_parameters" {
		t.Errorf("Expected error 'missing_parameters', got '%s'", errorResp.Error)
	}
}

func TestDrawHandler_InvalidDeckOptions(t *testing.T) {
	os.Setenv("CLOUDFRONT_URL", "https://test.cloudfront.net")

	req := events.APIGatewayV2HTTPRequest{
		RequestContext: events.APIGatewayV2HTTPRequestContext{
			HTTP: events.APIGatewayV2HTTPRequestContextHTTPDescription{
				Method: "POST",
			},
		},
		Body: `{"deckSize": "Invalid Deck", "deckReverse": "Upright only", "numCards": 5}`,
	}

	resp, err := drawHandler(req)
	if err != nil {
		t.Fatalf("Expected no error, got %v", err)
	}

	if resp.StatusCode != 400 {
		t.Errorf("Expected status 400, got %d", resp.StatusCode)
	}

	var errorResp errorResponse
	if err := json.Unmarshal([]byte(resp.Body), &errorResp); err != nil {
		t.Fatalf("Failed to parse error response: %v", err)
	}

	if errorResp.Error != "invalid_deck_options" {
		t.Errorf("Expected error 'invalid_deck_options', got '%s'", errorResp.Error)
	}
}

func TestDrawHandler_ValidRequest_MajorArcana(t *testing.T) {
	os.Setenv("CLOUDFRONT_URL", "https://test.cloudfront.net")

	req := events.APIGatewayV2HTTPRequest{
		RequestContext: events.APIGatewayV2HTTPRequestContext{
			HTTP: events.APIGatewayV2HTTPRequestContextHTTPDescription{
				Method: "POST",
			},
		},
		Body: `{"deckSize": "Major Arcana only", "deckReverse": "Upright only", "numCards": 5}`,
	}

	resp, err := drawHandler(req)
	if err != nil {
		t.Fatalf("Expected no error, got %v", err)
	}

	if resp.StatusCode != 200 {
		t.Errorf("Expected status 200, got %d", resp.StatusCode)
	}

	var drawResp drawResponse
	if err := json.Unmarshal([]byte(resp.Body), &drawResp); err != nil {
		t.Fatalf("Failed to parse draw response: %v", err)
	}

	if len(drawResp.DrawnCards) != 5 {
		t.Errorf("Expected 5 cards, got %d", len(drawResp.DrawnCards))
	}

	// Verify CloudFront URL is prepended
	for _, card := range drawResp.DrawnCards {
		if len(card.Image) < 27 || card.Image[:27] != "https://test.cloudfront.net" {
			t.Errorf("Expected CloudFront URL prefix, got %s", card.Image)
		}
	}
}

func TestDrawHandler_ValidRequest_FullDeck(t *testing.T) {
	os.Setenv("CLOUDFRONT_URL", "https://test.cloudfront.net")

	req := events.APIGatewayV2HTTPRequest{
		RequestContext: events.APIGatewayV2HTTPRequestContext{
			HTTP: events.APIGatewayV2HTTPRequestContextHTTPDescription{
				Method: "POST",
			},
		},
		Body: `{"deckSize": "Full Deck", "deckReverse": "Upright only", "numCards": 10}`,
	}

	resp, err := drawHandler(req)
	if err != nil {
		t.Fatalf("Expected no error, got %v", err)
	}

	if resp.StatusCode != 200 {
		t.Errorf("Expected status 200, got %d", resp.StatusCode)
	}

	var drawResp drawResponse
	if err := json.Unmarshal([]byte(resp.Body), &drawResp); err != nil {
		t.Fatalf("Failed to parse draw response: %v", err)
	}

	if len(drawResp.DrawnCards) != 10 {
		t.Errorf("Expected 10 cards, got %d", len(drawResp.DrawnCards))
	}
}

func TestDrawHandler_ValidRequest_WithReversals(t *testing.T) {
	os.Setenv("CLOUDFRONT_URL", "https://test.cloudfront.net")

	req := events.APIGatewayV2HTTPRequest{
		RequestContext: events.APIGatewayV2HTTPRequestContext{
			HTTP: events.APIGatewayV2HTTPRequestContextHTTPDescription{
				Method: "POST",
			},
		},
		Body: `{"deckSize": "Full Deck", "deckReverse": "Upright and reversed", "numCards": 8}`,
	}

	resp, err := drawHandler(req)
	if err != nil {
		t.Fatalf("Expected no error, got %v", err)
	}

	if resp.StatusCode != 200 {
		t.Errorf("Expected status 200, got %d", resp.StatusCode)
	}

	var drawResp drawResponse
	if err := json.Unmarshal([]byte(resp.Body), &drawResp); err != nil {
		t.Fatalf("Failed to parse draw response: %v", err)
	}

	if len(drawResp.DrawnCards) != 8 {
		t.Errorf("Expected 8 cards, got %d", len(drawResp.DrawnCards))
	}
}

func TestDrawHandler_DefaultNumCards(t *testing.T) {
	os.Setenv("CLOUDFRONT_URL", "https://test.cloudfront.net")

	req := events.APIGatewayV2HTTPRequest{
		RequestContext: events.APIGatewayV2HTTPRequestContext{
			HTTP: events.APIGatewayV2HTTPRequestContextHTTPDescription{
				Method: "POST",
			},
		},
		Body: `{"deckSize": "Major Arcana only", "deckReverse": "Upright only"}`,
	}

	resp, err := drawHandler(req)
	if err != nil {
		t.Fatalf("Expected no error, got %v", err)
	}

	if resp.StatusCode != 200 {
		t.Errorf("Expected status 200, got %d", resp.StatusCode)
	}

	var drawResp drawResponse
	if err := json.Unmarshal([]byte(resp.Body), &drawResp); err != nil {
		t.Fatalf("Failed to parse draw response: %v", err)
	}

	if len(drawResp.DrawnCards) != 8 {
		t.Errorf("Expected default 8 cards, got %d", len(drawResp.DrawnCards))
	}
}

func TestDrawHandler_TooManyCards(t *testing.T) {
	os.Setenv("CLOUDFRONT_URL", "https://test.cloudfront.net")

	req := events.APIGatewayV2HTTPRequest{
		RequestContext: events.APIGatewayV2HTTPRequestContext{
			HTTP: events.APIGatewayV2HTTPRequestContextHTTPDescription{
				Method: "POST",
			},
		},
		Body: `{"deckSize": "Major Arcana only", "deckReverse": "Upright only", "numCards": 100}`,
	}

	resp, err := drawHandler(req)
	if err != nil {
		t.Fatalf("Expected no error, got %v", err)
	}

	if resp.StatusCode != 200 {
		t.Errorf("Expected status 200, got %d", resp.StatusCode)
	}

	var drawResp drawResponse
	if err := json.Unmarshal([]byte(resp.Body), &drawResp); err != nil {
		t.Fatalf("Failed to parse draw response: %v", err)
	}

	// Major Arcana has 22 cards
	if len(drawResp.DrawnCards) != 22 {
		t.Errorf("Expected 22 cards (all major arcana), got %d", len(drawResp.DrawnCards))
	}

	if drawResp.Message != "There are no more cards to display." {
		t.Errorf("Expected warning message, got '%s'", drawResp.Message)
	}
}

func TestGetDeck_MajorArcana(t *testing.T) {
	deck := getDeck("Major Arcana only", "Upright only")
	if deck == nil {
		t.Fatal("Expected deck, got nil")
	}
	if len(deck) != 22 {
		t.Errorf("Expected 22 major arcana cards, got %d", len(deck))
	}
}

func TestGetDeck_MinorArcana(t *testing.T) {
	deck := getDeck("Minor Arcana only", "Upright only")
	if deck == nil {
		t.Fatal("Expected deck, got nil")
	}
	if len(deck) != 56 {
		t.Errorf("Expected 56 minor arcana cards, got %d", len(deck))
	}
}

func TestGetDeck_FullDeck(t *testing.T) {
	deck := getDeck("Full Deck", "Upright only")
	if deck == nil {
		t.Fatal("Expected deck, got nil")
	}
	if len(deck) != 78 {
		t.Errorf("Expected 78 cards in full deck, got %d", len(deck))
	}
}

func TestGetDeck_InvalidDeckSize(t *testing.T) {
	deck := getDeck("Invalid Size", "Upright only")
	if deck != nil {
		t.Error("Expected nil for invalid deck size")
	}
}

func TestShuffle(t *testing.T) {
	deck := getDeck("Major Arcana only", "Upright only")
	original := make([]tarotDeck, len(deck))
	copy(original, deck)

	shuffled := shuffle(deck)

	if len(shuffled) != len(original) {
		t.Errorf("Shuffle changed deck size: expected %d, got %d", len(original), len(shuffled))
	}

	// Check that shuffle actually changed the order (not 100% guaranteed but very likely)
	allSame := true
	for i := range shuffled {
		if shuffled[i].NameSuit != original[i].NameSuit {
			allSame = false
			break
		}
	}

	if allSame && len(shuffled) > 1 {
		t.Error("Shuffle did not change card order")
	}
}

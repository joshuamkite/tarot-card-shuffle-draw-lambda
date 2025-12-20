package main

import (
	"crypto/rand"
	"encoding/json"
	"net/http"
	"os"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

type tarotDeck struct {
	Number   string `json:"number"`
	NameSuit string `json:"nameSuit"`
	Reversed string `json:"reversed"`
	Image    string `json:"image"`
}

type drawRequest struct {
	DeckSize    string `json:"deckSize"`
	DeckReverse string `json:"deckReverse"`
	NumCards    int    `json:"numCards"`
}

type drawResponse struct {
	DrawnCards []tarotDeck `json:"drawnCards"`
	Message    string      `json:"message"`
}

type errorResponse struct {
	Error   string `json:"error"`
	Message string `json:"message"`
}

var (
	cloudFrontURL = os.Getenv("CLOUDFRONT_URL")
)

func main() {
	lambda.Start(drawHandler)
}

func drawHandler(req events.APIGatewayV2HTTPRequest) (events.APIGatewayV2HTTPResponse, error) {
	// CORS headers for all responses
	corsHeaders := map[string]string{
		"Content-Type":                 "application/json",
		"Access-Control-Allow-Origin":  "https://tarot-react.joshuakite.co.uk",
		"Access-Control-Allow-Methods": "POST, OPTIONS",
		"Access-Control-Allow-Headers": "content-type, authorization",
	}

	// Handle OPTIONS preflight request
	if req.RequestContext.HTTP.Method == "OPTIONS" {
		return events.APIGatewayV2HTTPResponse{
			StatusCode: http.StatusOK,
			Headers:    corsHeaders,
		}, nil
	}

	// Only allow POST for actual requests
	if req.RequestContext.HTTP.Method != "POST" {
		body, _ := json.Marshal(errorResponse{
			Error:   "method_not_allowed",
			Message: "Only POST requests are allowed",
		})
		return events.APIGatewayV2HTTPResponse{
			StatusCode: http.StatusMethodNotAllowed,
			Headers:    corsHeaders,
			Body:       string(body),
		}, nil
	}

	// Decode JSON request body
	var drawReq drawRequest
	if err := json.Unmarshal([]byte(req.Body), &drawReq); err != nil {
		body, _ := json.Marshal(errorResponse{
			Error:   "invalid_request",
			Message: "Invalid JSON in request body",
		})
		return events.APIGatewayV2HTTPResponse{
			StatusCode: http.StatusBadRequest,
			Headers:    corsHeaders,
			Body:       string(body),
		}, nil
	}

	// Validate required fields
	if drawReq.DeckSize == "" || drawReq.DeckReverse == "" {
		body, _ := json.Marshal(errorResponse{
			Error:   "missing_parameters",
			Message: "deckSize and deckReverse are required",
		})
		return events.APIGatewayV2HTTPResponse{
			StatusCode: http.StatusBadRequest,
			Headers:    corsHeaders,
			Body:       string(body),
		}, nil
	}

	// Default numCards if not provided or invalid
	if drawReq.NumCards < 1 {
		drawReq.NumCards = 8
	}

	decks := getDeck(drawReq.DeckSize, drawReq.DeckReverse)
	if decks == nil {
		body, _ := json.Marshal(errorResponse{
			Error:   "invalid_deck_options",
			Message: "Invalid deck size or reverse option",
		})
		return events.APIGatewayV2HTTPResponse{
			StatusCode: http.StatusBadRequest,
			Headers:    corsHeaders,
			Body:       string(body),
		}, nil
	}

	totalCards := len(decks)

	message := ""
	if drawReq.NumCards > totalCards {
		drawReq.NumCards = totalCards
		message = "There are no more cards to display."
	}

	shuffledDeck := shuffle(decks)
	drawnCards := shuffledDeck[:drawReq.NumCards]

	// Update image URLs to use CloudFront
	for i := range drawnCards {
		drawnCards[i].Image = cloudFrontURL + "/images/" + drawnCards[i].Image
	}

	// Send JSON response
	body, _ := json.Marshal(drawResponse{
		DrawnCards: drawnCards,
		Message:    message,
	})
	return events.APIGatewayV2HTTPResponse{
		StatusCode: http.StatusOK,
		Headers:    corsHeaders,
		Body:       string(body),
	}, nil
}

// Functions for generating the deck, shuffling, etc. remain the same

var majorCards = map[string]string{
	"I": "The Magician", "II": "The Papess", "III": "The Empress", "IV": "The Emperor",
	"V": "The Heirophant", "VI": "The Lovers", "VII": "The Chariot", "VIII": "Justice",
	"IX": "The Hermit", "X": "The Wheel Of Fortune", "XI": "Strength", "XII": "The Hanged Man",
	"XIII": "Death", "XIV": "Temperance", "XV": "The Devil", "XVI": "The Tower",
	"XVII": "The Star", "XVIII": "The Moon", "XIX": "The Sun", "XX": "The Last Judgment",
	"XXI": "The World", "_": "The Fool",
}

var minorSuits = map[string]string{
	"Cups": "Cups", "Wands": "Wands", "Swords": "Swords", "Pents": "Pentacles",
}

var minorCards = map[string]string{
	"01": "Ace", "02": "Two", "03": "Three", "04": "Four", "05": "Five",
	"06": "Six", "07": "Seven", "08": "Eight", "09": "Nine", "10": "Ten",
	"11": "Page", "12": "Knight", "13": "Queen", "14": "King",
}

var majorImages = map[string]string{
	"I": "RWS_Tarot_01_Magician.jpg", "II": "RWS_Tarot_02_High_Priestess.jpg", "III": "RWS_Tarot_03_Empress.jpg",
	"IV": "RWS_Tarot_04_Emperor.jpg", "V": "RWS_Tarot_05_Hierophant.jpg", "VI": "RWS_Tarot_06_Lovers.jpg",
	"VII": "RWS_Tarot_07_Chariot.jpg", "VIII": "RWS_Tarot_08_Strength.jpg", "IX": "RWS_Tarot_09_Hermit.jpg",
	"X": "RWS_Tarot_10_Wheel_of_Fortune.jpg", "XI": "RWS_Tarot_11_Justice.jpg", "XII": "RWS_Tarot_12_Hanged_Man.jpg",
	"XIII": "RWS_Tarot_13_Death.jpg", "XIV": "RWS_Tarot_14_Temperance.jpg", "XV": "RWS_Tarot_15_Devil.jpg",
	"XVI": "RWS_Tarot_16_Tower.jpg", "XVII": "RWS_Tarot_17_Star.jpg", "XVIII": "RWS_Tarot_18_Moon.jpg",
	"XIX": "RWS_Tarot_19_Sun.jpg", "XX": "RWS_Tarot_20_Judgement.jpg", "XXI": "RWS_Tarot_21_World.jpg",
	"_": "RWS_Tarot_00_Fool.jpg",
}

var minorImages = map[string]string{
	"Cups01": "Cups01.jpg", "Cups02": "Cups02.jpg", "Cups03": "Cups03.jpg",
	"Cups04": "Cups04.jpg", "Cups05": "Cups05.jpg", "Cups06": "Cups06.jpg",
	"Cups07": "Cups07.jpg", "Cups08": "Cups08.jpg", "Cups09": "Cups09.jpg",
	"Cups10": "Cups10.jpg", "Cups11": "Cups11.jpg", "Cups12": "Cups12.jpg",
	"Cups13": "Cups13.jpg", "Cups14": "Cups14.jpg", "Pents01": "Pents01.jpg",
	"Pents02": "Pents02.jpg", "Pents03": "Pents03.jpg", "Pents04": "Pents04.jpg",
	"Pents05": "Pents05.jpg", "Pents06": "Pents06.jpg", "Pents07": "Pents07.jpg",
	"Pents08": "Pents08.jpg", "Pents09": "Pents09.jpg", "Pents10": "Pents10.jpg",
	"Pents11": "Pents11.jpg", "Pents12": "Pents12.jpg", "Pents13": "Pents13.jpg",
	"Pents14": "Pents14.jpg", "Swords01": "Swords01.jpg", "Swords02": "Swords02.jpg",
	"Swords03": "Swords03.jpg", "Swords04": "Swords04.jpg", "Swords05": "Swords05.jpg",
	"Swords06": "Swords06.jpg", "Swords07": "Swords07.jpg", "Swords08": "Swords08.jpg",
	"Swords09": "Swords09.jpg", "Swords10": "Swords10.jpg", "Swords11": "Swords11.jpg",
	"Swords12": "Swords12.jpg", "Swords13": "Swords13.jpg", "Swords14": "Swords14.jpg",
	"Wands01": "Wands01.jpg", "Wands02": "Wands02.jpg", "Wands03": "Wands03.jpg",
	"Wands04": "Wands04.jpg", "Wands05": "Wands05.jpg", "Wands06": "Wands06.jpg",
	"Wands07": "Wands07.jpg", "Wands08": "Wands08.jpg", "Wands09": "Tarot_Nine_of_Wands.jpg",
	"Wands10": "Wands10.jpg", "Wands11": "Wands11.jpg", "Wands12": "Wands12.jpg",
	"Wands13": "Wands13.jpg", "Wands14": "Wands14.jpg",
}

// getDeck function generates the deck based on input
func getDeck(deckSize, deckReverse string) []tarotDeck {
	var decks []tarotDeck
	switch deckSize {
	case "Major Arcana only":
		decks = majorArcana()
	case "Minor Arcana only":
		decks = minorArcana()
	case "Full Deck":
		decks = append(majorArcana(), minorArcana()...)
	default:
		// If deckSize is invalid, return nil
		return nil
	}

	if deckReverse == "Upright and reversed" {
		decks = includeReversed(decks)
	}

	return decks
}

// majorArcana generates the major arcana deck
func majorArcana() []tarotDeck {
	var majorArcana []tarotDeck
	for key, value := range majorCards {
		majorArcana = append(majorArcana, tarotDeck{
			Number:   key,
			NameSuit: value,
			Image:    majorImages[key]})
	}
	return majorArcana
}

// minorArcana generates the minor arcana deck
func minorArcana() []tarotDeck {
	var minorArcana []tarotDeck
	for suit, fullSuitName := range minorSuits {
		for number, fullNumberName := range minorCards {
			key := suit + number
			minorArcana = append(minorArcana, tarotDeck{
				Number:   fullNumberName,
				NameSuit: "of " + fullSuitName,
				Image:    minorImages[key]})
		}
	}
	return minorArcana
}

// includeReversed includes reversed cards in the deck
func includeReversed(decks []tarotDeck) []tarotDeck {
	var newDecks []tarotDeck
	for i := range decks {
		b := make([]byte, 1)
		rand.Read(b)
		if b[0]%2 == 0 {
			newDecks = append(newDecks, tarotDeck{
				Number:   decks[i].Number,
				NameSuit: decks[i].NameSuit,
				Image:    decks[i].Image,
			})
		} else {
			newDecks = append(newDecks, tarotDeck{
				Number:   decks[i].Number,
				NameSuit: decks[i].NameSuit,
				Reversed: "(Reversed)",
				Image:    decks[i].Image,
			})
		}
	}
	return newDecks
}

// shuffle shuffles the deck
func shuffle(decks []tarotDeck) []tarotDeck {
	for i := range decks {
		b := make([]byte, 1)
		rand.Read(b)
		j := int(b[0]) % (i + 1)
		decks[i], decks[j] = decks[j], decks[i]
	}
	return decks
}

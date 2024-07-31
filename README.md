# Tarot Card Shuffle Lambda

Tarot Card Shuffle Draw is a web application that simulates a tarot card reading. Users can choose different decks, specify the number of cards to draw, and include reversed cards in the draw. Public domain illustrations of the cards are presented with the results. 

- [Tarot Card Shuffle Lambda](#tarot-card-shuffle-lambda)
  - [Features](#features)
  - [Deployment](#deployment)
  - [API test with CURL](#api-test-with-curl)
  - [Check API Gateway](#check-api-gateway)
  - [Usage](#usage)
    - [Web Interface](#web-interface)
    - [API Endpoints](#api-endpoints)
  - [Cleanup](#cleanup)

## Features

- **Deck Options**: Full Deck, Major Arcana only, Minor Arcana only
- **Reversed Cards**: Option to include reversed cards
- **Random Draw**: Secure randomness using `crypto/rand`
- **Web Interface**: User-friendly web interface built with Gin

## Deployment

sam build && \
sam deploy \
    --stack-name TarotCardDrawApp \
    --capabilities CAPABILITY_IAM \
    --region eu-west-2 \
    --resolve-s3

## API test with CURL

```bash


# Test GET /
curl -i -X GET https://ypo33qaaf5.execute-api.eu-west-2.amazonaws.com/

# Test POST /draw
curl -i -X POST https://ypo33qaaf5.execute-api.eu-west-2.amazonaws.com/draw -H "Content-Type: application/json" -d '{}'

# Test GET /license
curl -i -X GET https://ypo33qaaf5.execute-api.eu-west-2.amazonaws.com/license




curl -X POST https://t7lfpot8l9.execute-api.eu-west-2.amazonaws.com/draw -H "Content-Type: application/json" -d '{
  "deckSize": "Full Deck",
  "deckReverse": "Upright and reversed",
  "numCards": 8
}'


aws lambda invoke --function-name DrawFunction --payload file://payload.json response.json


```

## Check API Gateway

check_api_gateway.sh

## Usage

### Web Interface

1. **Choose the deck type**: Full Deck/ Major Arcana only/ Minor Arcana only.
2. **Select reversed cards option**: Include or exclude reversed cards.
3. **Specify the number of cards to draw**.
4. **Click "Draw Cards"** to see the results.

### API Endpoints

- `GET /`: Displays the options page.
- `POST /draw`: Handles drawing cards based on user input.
- `GET /license`: Displays the license page.

## Cleanup

sam delete --stack-name TarotCardDrawApp --region eu-west-2

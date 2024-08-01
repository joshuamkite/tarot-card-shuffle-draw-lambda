# Tarot Card Shuffle Lambda

Tarot Card Shuffle Draw is a free and open-source project that shuffles and returns a selection of Tarot cards. Users can choose different decks, specify the number of cards to draw, and include reversed cards in the draw. Public domain illustrations of the cards are presented with the results. This port of the application is deployed as AWS Lambda microservices orchestrated with API Gateway and backed with S3 and CloudFront. There are other ports available - see [Alternative Deployment Ports](#alternative-deployment-ports) below.

- [Tarot Card Shuffle Lambda](#tarot-card-shuffle-lambda)
  - [Features](#features)
  - [Deployment](#deployment)
    - [Prerequisites](#prerequisites)
    - [Steps](#steps)
  - [Usage](#usage)
    - [Web Interface](#web-interface)
    - [API Endpoints](#api-endpoints)
  - [Cleanup](#cleanup)
  - [Alternative Deployment Ports](#alternative-deployment-ports)

## Features

- **Deck Options**: Full Deck, Major Arcana only, Minor Arcana only.
- **Reversed Cards**: Option to include reversed cards in the draw.
- **Random Draw**: Utilizes high-quality randomness using `crypto/rand`.
- **Web Interface**: User-friendly web interface for easy interaction.
- **API Endpoints**: Flexible API for programmatic access.

## Deployment

### Prerequisites
- AWS CLI configured with necessary permissions.
- AWS SAM CLI installed.

### Steps

1. **Build and Deploy the SAM Application:**

    ```sh
   sam build && sam deploy \
       --stack-name TarotCardDrawApp \
       --capabilities CAPABILITY_IAM \
       --region eu-west-2 \
       --resolve-s3 \
       --parameter-overrides ParameterKey=DomainName,ParameterValue=$DOMAINNAME \
                            ParameterKey=HostedZoneId,ParameterValue=$HOSTEDZONEID
    ```

2. **Upload Images to S3:**
   - Use the provided script to upload images.
   
   ```sh
   sh dev_tooling/images_to_s3.sh
   ```

3. **Invalidate CloudFront Cache:**
   - Invalidate the CloudFront cache to ensure updated content is served.
   
   ```sh
   sh dev_tooling/cloudfront-invalidation.sh
   ```

## Usage

### Web Interface

1. **Choose the deck type**: Select Full Deck, Major Arcana only, or Minor Arcana only.
2. **Select reversed cards option**: Decide whether to include reversed cards.
3. **Specify the number of cards to draw**.
4. **Click "Draw Cards"** to see the results.

### API Endpoints

- **GET /**: Displays the options page.
- **POST /draw**: Handles drawing cards based on user input.
- **GET /license**: Displays the license page.

## Cleanup

To delete the deployed stack and associated resources:

```sh
sam delete --stack-name TarotCardDrawApp --region "$AWS_REGION"
```

## Alternative Deployment Ports

There is a cross platform command line port (sorry, no illustrations!) available with binaries packaged for various operating systems - see [tarot-card-shuffle-draw](https://github.com/joshuamkite/tarot-card-shuffle-draw)

There is a dockerised port with accompanying Helm chart that can be run in plain docker or installed on Kubernetes - see [tarot-card-shuffle-draw-web](https://github.com/joshuamkite/tarot-card-shuffle-draw-web). A pre-built Docker image accompanies each release on [GitHub Container Registry](ghcr.io/joshuamkite/tarot-card-shuffle-draw-web/tarot_shuffle_draw)

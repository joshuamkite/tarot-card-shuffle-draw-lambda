package main

import (
	"log"
	"net/http"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	ginadapter "github.com/awslabs/aws-lambda-go-api-proxy/gin"
	"github.com/gin-gonic/gin"
)

var optionsGinLambda *ginadapter.GinLambda

func init() {
	log.Printf("Gin cold start for showOptionsPage")
	r := gin.Default()
	r.LoadHTMLGlob("templates/*")
	r.GET("/", showOptionsPage)
	optionsGinLambda = ginadapter.New(r)
}

func main() {
	gin.SetMode(gin.ReleaseMode)
	lambda.Start(optionsHandler)
}

func optionsHandler(req events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	log.Printf("Received request: %+v", req)
	resp, err := optionsGinLambda.Proxy(req)
	if err != nil {
		log.Printf("Error processing request: %v", err)
		return events.APIGatewayProxyResponse{
			StatusCode: http.StatusInternalServerError,
			Body:       err.Error(),
		}, nil
	}
	if resp.Headers == nil {
		resp.Headers = map[string]string{}
	}
	resp.Headers["Content-Type"] = "text/html"
	return resp, nil
}

func showOptionsPage(c *gin.Context) {
	c.Header("Content-Type", "text/html")
	c.HTML(http.StatusOK, "options.html", nil)
}

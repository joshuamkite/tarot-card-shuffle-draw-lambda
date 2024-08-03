package main

import (
	"log"
	"net/http"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	ginadapter "github.com/awslabs/aws-lambda-go-api-proxy/gin"
	"github.com/gin-gonic/gin"
)

var ginLambda *ginadapter.GinLambda

func init() {
	// log.Printf("Gin cold start for showLicensePage")
	r := gin.Default()
	r.LoadHTMLGlob("templates/*")
	r.GET("/", showLicensePage)
	ginLambda = ginadapter.New(r)
}

func main() {
	gin.SetMode(gin.ReleaseMode)
	lambda.Start(licenseHandler)
}

func licenseHandler(req events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	// log.Printf("Received request: %+v", req)
	resp, err := ginLambda.Proxy(req)
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

func showLicensePage(c *gin.Context) {
	c.Header("Content-Type", "text/html")
	c.HTML(http.StatusOK, "license.html", nil)
}

package main

import (
	"embed"
	"html/template"
	"log"
	"net/http"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/awslabs/aws-lambda-go-api-proxy/httpadapter"
)

//go:embed templates/*
var content embed.FS

var (
	licenseLambda *httpadapter.HandlerAdapterV2
	tmpl          *template.Template
)

func init() {
	log.Printf("Cold start for showLicensePage")

	// Parse templates from the embedded filesystem
	var err error
	tmpl, err = template.ParseFS(content, "templates/*")
	if err != nil {
		log.Fatalf("Failed to parse templates: %v", err)
	}

	// Create a new ServeMux instead of using default
	mux := http.NewServeMux()
	mux.HandleFunc("/license", showLicensePage)

	// Initialize the Lambda handler with the custom mux
	licenseLambda = httpadapter.NewV2(mux)
	log.Printf("Initialization complete")
}

func main() {
	lambda.Start(licenseHandler)
}

func licenseHandler(req events.APIGatewayV2HTTPRequest) (events.APIGatewayV2HTTPResponse, error) {
	log.Printf("Received request: %+v", req)
	resp, err := licenseLambda.Proxy(req)
	if err != nil {
		log.Printf("Error processing request: %v", err)
		return events.APIGatewayV2HTTPResponse{
			StatusCode: http.StatusInternalServerError,
			Body:       err.Error(),
		}, nil
	}

	if resp.Headers == nil {
		resp.Headers = map[string]string{}
	}
	resp.Headers["Content-Type"] = "text/html"
	return events.APIGatewayV2HTTPResponse{
		StatusCode: resp.StatusCode,
		Headers:    resp.Headers,
		Body:       resp.Body,
	}, nil
}

func showLicensePage(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/html")
	err := tmpl.ExecuteTemplate(w, "license.html", nil)
	if err != nil {
		log.Printf("Error executing template: %v", err)
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}
